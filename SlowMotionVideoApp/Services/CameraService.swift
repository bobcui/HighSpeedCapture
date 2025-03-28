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

public class CameraService {
    
    // MARK: - Properties
    var session: AVCaptureSession?
    var delegate: AVCaptureFileOutputRecordingDelegate?
    var videoOutput: AVCaptureMovieFileOutput?
    
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
        
        // Add video input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
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
            
            let videoInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                throw CameraError.inputsAreInvalid
            }
        } catch {
            throw CameraError.inputsAreInvalid
        }
        
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