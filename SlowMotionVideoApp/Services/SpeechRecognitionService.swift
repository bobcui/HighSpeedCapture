import Foundation
import Speech

enum SpeechRecognitionError: Error {
    case notAuthorized
    case notAvailable
    case recognitionFailed
}

protocol SpeechRecognitionDelegate: AnyObject {
    func speechRecognitionDidDetectCommand(_ command: String)
}

class SpeechRecognitionService {
    
    // MARK: - Properties
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var isListening = false
    private let commandKeywords = ["ready"]
    
    weak var delegate: SpeechRecognitionDelegate?
    
    // MARK: - Init
    init() {
        // Initialize speech recognizer with the device locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    // MARK: - Public Methods
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            var isAuthorized = false
            
            switch status {
            case .authorized:
                isAuthorized = true
            case .denied, .restricted, .notDetermined:
                isAuthorized = false
            @unknown default:
                isAuthorized = false
            }
            
            DispatchQueue.main.async {
                completion(isAuthorized)
            }
        }
    }
    
    func startListening() throws {
        // Check authorization status
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechRecognitionError.notAuthorized
        }
        
        // Check if recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.notAvailable
        }
        
        // Cancel any existing task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognitionError.recognitionFailed
        }
        
        // Configure request
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                // Process result
                let transcription = result.bestTranscription.formattedString.lowercased()
                isFinal = result.isFinal
                
                // Check for command keywords
                for command in self.commandKeywords {
                    if transcription.contains(command) {
                        DispatchQueue.main.async {
                            self.delegate?.speechRecognitionDidDetectCommand(command)
                        }
                        break
                    }
                }
            }
            
            if error != nil || isFinal {
                // Stop audio engine and restart recognition
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                // Restart listening if not stopped
                if self.isListening {
                    try? self.startListening()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
    }
    
    func stopListening() {
        isListening = false
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}