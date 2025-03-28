import Foundation
import AVFoundation
import UIKit

enum CameraError: Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case unknown
}

public enum CameraPosition {
    case front
    case back
}

public class CameraService {
    
    // MARK: - Properties
    var session: AVCaptureSession?
    var delegate: AVCaptureFileOutputRecordingDelegate?
    var videoOutput: AVCaptureMovieFileOutput?
    var currentCameraPosition: CameraPosition = .back
    var videoDeviceInput: AVCaptureDeviceInput?
    
    let sessionQueue = DispatchQueue(label: "com.example.sessionQueue")
    let videoSettings: VideoSettings
    var recordedClips: [URL] = []
    var isRecording = false
    
    init(videoSettings: VideoSettings = .default) {
        self.videoSettings = videoSettings
    }
    
    // MARK: - Camera Setup
    func checkPermissions() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            requestPermissions()
            return false
        default:
            return false
        }
    }
    
    func requestPermissions() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            self.sessionQueue.resume()
        }
    }
    
    func setupCamera() throws {
        let session = AVCaptureSession()
        self.session = session
        
        session.beginConfiguration()
        
        // Set the video quality preset
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add video input for the current camera position
        try setupVideoInput(position: currentCameraPosition, session: session)
        
        // Add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // Add video output
        let videoOutput = AVCaptureMovieFileOutput()
        self.videoOutput = videoOutput
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            throw CameraError.unknown
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - Camera Control
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.session else { return }
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, let session = self.session else { return }
            if session.isRunning {
                session.stopRunning()
            }
        }
    }
    
    // MARK: - Recording Methods
    func startRecording(completion: @escaping (Error?) -> Void) {
        guard let videoOutput = videoOutput, !isRecording else {
            completion(CameraError.captureSessionAlreadyRunning)
            return
        }
        
        guard let delegate = delegate else {
            completion(CameraError.invalidOperation)
            return
        }
        
        let outputURL = newRecordingURL()
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Set max duration
            videoOutput.maxRecordedDuration = CMTime(seconds: Double(self.videoSettings.clipDuration), preferredTimescale: 600)
            
            // Start recording
            videoOutput.startRecording(to: outputURL, recordingDelegate: delegate)
            self.isRecording = true
            
            // Schedule stop after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.videoSettings.clipDuration)) {
                self.stopRecording { error in
                    completion(error)
                }
            }
        }
    }
    
    func stopRecording(completion: @escaping (Error?) -> Void) {
        guard let videoOutput = videoOutput, isRecording else {
            completion(CameraError.invalidOperation)
            return
        }
        
        sessionQueue.async { [weak self] in
            videoOutput.stopRecording()
            self?.isRecording = false
            completion(nil)
        }
    }
    
    private func newRecordingURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(Date().timeIntervalSince1970).mov"
        return tempDir.appendingPathComponent(fileName)
    }
    
    // MARK: - Camera Position Methods
    
    /// Setup video input for the specified camera position
    private func setupVideoInput(position: CameraPosition, session: AVCaptureSession) throws {
        // Get device position
        let devicePosition: AVCaptureDevice.Position = position == .back ? .back : .front
        
        // Find camera device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition) else {
            throw CameraError.noCamerasAvailable
        }
        
        do {
            // Configure device for high frame rate
            try device.lockForConfiguration()
            if device.activeFormat.isHighFrameRateSupported(fps: videoSettings.frameRate) {
                device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(videoSettings.frameRate))
                device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(videoSettings.frameRate))
            }
            device.unlockForConfiguration()
            
            // Create and add video input
            let videoInput = try AVCaptureDeviceInput(device: device)
            self.videoDeviceInput = videoInput
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                throw CameraError.inputsAreInvalid
            }
        } catch {
            throw CameraError.inputsAreInvalid
        }
    }
    
    /// Switch between front and back cameras
    func switchCamera(completion: @escaping (Error?) -> Void) {
        guard let session = session else {
            completion(CameraError.captureSessionIsMissing)
            return
        }
        
        // Don't allow switching during recording
        if isRecording {
            completion(CameraError.captureSessionAlreadyRunning)
            return
        }
        
        // Execute on session queue
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            session.beginConfiguration()
            
            // Remove current input
            if let currentInput = self.videoDeviceInput {
                session.removeInput(currentInput)
            }
            
            // Determine new position
            let newPosition: CameraPosition = self.currentCameraPosition == .back ? .front : .back
            self.currentCameraPosition = newPosition
            
            do {
                // Setup new camera input
                try self.setupVideoInput(position: newPosition, session: session)
                session.commitConfiguration()
                completion(nil)
            } catch {
                // If front camera is not available, revert to back camera
                if newPosition == .front {
                    self.currentCameraPosition = .back
                    do {
                        try self.setupVideoInput(position: .back, session: session)
                        session.commitConfiguration()
                        completion(nil)
                    } catch {
                        session.commitConfiguration()
                        completion(error)
                    }
                } else {
                    session.commitConfiguration()
                    completion(error)
                }
            }
        }
    }
}

// Extension for frame rate support
extension AVCaptureDevice.Format {
    func isHighFrameRateSupported(fps: Int) -> Bool {
        let ranges = videoSupportedFrameRateRanges
        for range in ranges where range.maxFrameRate >= Float64(fps) {
            return true
        }
        return false
    }
}