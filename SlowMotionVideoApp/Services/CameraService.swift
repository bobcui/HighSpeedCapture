import AVFoundation
import UIKit

class CameraService: NSObject {
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var videoDevice: AVCaptureDevice?
    private var currentRecordingURL: URL?
    
    private var recordingTimer: Timer?
    private var recordingCompletionHandler: ((Bool, URL?) -> Void)?
    
    // Preview layer for showing camera feed
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Camera Setup
    func prepareCamera(frameRate: Int, completion: @escaping (Bool) -> Void) {
        // Check authorization status
        checkPermission { [weak self] granted in
            guard let self = self, granted else {
                completion(false)
                return
            }
            
            // Create capture session
            let session = AVCaptureSession()
            session.sessionPreset = .high
            self.captureSession = session
            
            // Find back camera with high frame rate support
            guard let device = self.findBestCamera(for: frameRate) else {
                completion(false)
                return
            }
            
            self.videoDevice = device
            
            do {
                // Configure device for high frame rate
                try device.lockForConfiguration()
                
                if device.activeFormat.isHighPhotoQualitySupported {
                    device.isHighPhotoQualityEnabled = true
                }
                
                // Find format that supports high frame rate
                if let formatWithHighFrameRate = CameraService.bestFormat(for: device, frameRate: frameRate) {
                    device.activeFormat = formatWithHighFrameRate
                    
                    // Set frame rate
                    let ranges = formatWithHighFrameRate.videoSupportedFrameRateRanges
                    if let frameRateRange = ranges.first(where: { $0.maxFrameRate >= Float64(frameRate) }) {
                        device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
                        device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
                    }
                }
                
                device.unlockForConfiguration()
                
                // Add device input to session
                let deviceInput = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                }
                
                // Setup movie file output
                let movieFileOutput = AVCaptureMovieFileOutput()
                if session.canAddOutput(movieFileOutput) {
                    session.addOutput(movieFileOutput)
                    self.videoOutput = movieFileOutput
                }
                
                // Setup preview layer
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer = previewLayer
                
                completion(true)
            } catch {
                print("Error setting up camera: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    private func findBestCamera(for frameRate: Int) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera],
            mediaType: .video,
            position: .back
        )
        
        // Find devices that support high frame rates
        for device in discoverySession.devices {
            if CameraService.bestFormat(for: device, frameRate: frameRate) != nil {
                return device
            }
        }
        
        // If no ideal device is found, return the default back camera
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    static func bestFormat(for device: AVCaptureDevice, frameRate: Int) -> AVCaptureDevice.Format? {
        // Find format that supports high frame rate
        var bestFormat: AVCaptureDevice.Format? = nil
        var maxDimension: Int32 = 0
        
        for format in device.formats {
            let ranges = format.videoSupportedFrameRateRanges
            
            // Check if this format supports our target frame rate
            guard let range = ranges.first(where: { $0.maxFrameRate >= Float64(frameRate) }) else {
                continue
            }
            
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let totalPixels = dimensions.width * dimensions.height
            
            // We want the highest resolution that supports our frame rate
            if totalPixels > maxDimension {
                maxDimension = totalPixels
                bestFormat = format
            }
        }
        
        return bestFormat
    }
    
    // MARK: - Session Control
    func startSession() {
        guard let captureSession = captureSession, !captureSession.isRunning else { return }
        
        // Start the capture session on a background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    func stopSession() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        
        // Stop the capture session on a background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    // MARK: - Recording
    func startRecording(duration: Int, completion: @escaping (Bool, URL?) -> Void) {
        guard let videoOutput = videoOutput, !videoOutput.isRecording else {
            completion(false, nil)
            return
        }
        
        // Create unique URL for recorded video
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let timestamp = Date().timeIntervalSince1970
        let url = documentsURL.appendingPathComponent("video_\(timestamp).mov")
        currentRecordingURL = url
        
        // Store completion handler
        recordingCompletionHandler = completion
        
        // Start recording
        videoOutput.startRecording(to: url, recordingDelegate: self)
        
        // Setup timer to stop recording after specified duration
        recordingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { [weak self] _ in
            self?.stopRecording()
        }
    }
    
    func stopRecording() {
        guard let videoOutput = videoOutput, videoOutput.isRecording else { return }
        
        // Invalidate timer if it exists
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Stop recording
        videoOutput.stopRecording()
    }
    
    // MARK: - Permissions
    private func checkPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraService: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let success = error == nil
        
        // Call completion handler if it exists
        if let completionHandler = recordingCompletionHandler {
            completionHandler(success, outputFileURL)
            recordingCompletionHandler = nil
        }
    }
}
