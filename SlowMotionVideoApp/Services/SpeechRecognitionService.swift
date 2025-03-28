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
    
    private(set) var isListening = false
    private let commandKeywords = ["ready"]
    
    // Voice training properties
    private var voiceTrainingEnabled = false
    private var confidenceThreshold: Float = 0.5  // Default threshold
    private var userVoiceProfile: [String: [Float]] = [:] // Store voice characteristics
    
    weak var delegate: SpeechRecognitionDelegate?
    
    // MARK: - Init
    init() {
        // Initialize speech recognizer with the device locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        // Load saved voice profile if available
        loadVoiceProfile()
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
                
                // Get recognition confidence if available (iOS 13+)
                var bestConfidence: Float = 0.0
                
                // Extract confidence from transcription segments if available
                for segment in result.bestTranscription.segments {
                    if #available(iOS 13.0, *), let confidence = segment.confidence as Float? {
                        bestConfidence = max(bestConfidence, confidence)
                    } else {
                        bestConfidence = 0.8 // Default confidence if not available
                    }
                }
                
                // Check for command keywords with confidence threshold
                for command in self.commandKeywords {
                    if transcription.contains(command) {
                        // If voice training is enabled, apply confidence threshold
                        if self.voiceTrainingEnabled {
                            // Only accept commands with confidence above threshold
                            if bestConfidence >= self.confidenceThreshold {
                                DispatchQueue.main.async {
                                    self.delegate?.speechRecognitionDidDetectCommand(command)
                                }
                            }
                        } else {
                            // If training is not enabled, use default behavior
                            DispatchQueue.main.async {
                                self.delegate?.speechRecognitionDidDetectCommand(command)
                            }
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
    
    // MARK: - Voice Training Methods
    
    /// Updates the voice profile based on training data
    /// - Parameters:
    ///   - command: The command used in training
    ///   - confidence: The confidence level achieved in training
    func updateVoiceProfile(for command: String, with confidence: Float) {
        // Only update if the confidence is good enough
        guard confidence > 0.4 else { return }
        
        // Create an entry for the command if it doesn't exist
        if userVoiceProfile[command] == nil {
            userVoiceProfile[command] = []
        }
        
        // Add the confidence value to the profile
        userVoiceProfile[command]?.append(confidence)
        
        // If we have enough samples, adjust the threshold
        if let confidenceValues = userVoiceProfile[command], confidenceValues.count >= 3 {
            // Calculate average confidence
            let averageConfidence = confidenceValues.reduce(0, +) / Float(confidenceValues.count)
            
            // Set threshold slightly below the average to account for variations
            let newThreshold = max(0.4, averageConfidence * 0.85)
            confidenceThreshold = newThreshold
        }
        
        // Save the updated profile
        saveVoiceProfile()
        
        // Enable voice training mode
        voiceTrainingEnabled = true
    }
    
    /// Saves the voice profile to UserDefaults
    private func saveVoiceProfile() {
        // Convert voice profile to a serializable format
        var serializedProfile: [String: [Float]] = [:]
        
        for (command, confidenceValues) in userVoiceProfile {
            serializedProfile[command] = confidenceValues
        }
        
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(serializedProfile) {
            UserDefaults.standard.set(data, forKey: "VoiceProfileData")
            UserDefaults.standard.set(confidenceThreshold, forKey: "VoiceConfidenceThreshold")
        }
    }
    
    /// Loads the voice profile from UserDefaults
    private func loadVoiceProfile() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "VoiceProfileData"),
           let storedProfile = try? JSONDecoder().decode([String: [Float]].self, from: data) {
            userVoiceProfile = storedProfile
            
            // Load threshold if available
            if let threshold = UserDefaults.standard.object(forKey: "VoiceConfidenceThreshold") as? Float {
                confidenceThreshold = threshold
            }
            
            // Enable voice training if we have data
            voiceTrainingEnabled = !userVoiceProfile.isEmpty
        }
    }
    
    /// Resets the voice profile
    func resetVoiceProfile() {
        userVoiceProfile = [:]
        confidenceThreshold = 0.5
        voiceTrainingEnabled = false
        
        // Remove from UserDefaults
        UserDefaults.standard.removeObject(forKey: "VoiceProfileData")
        UserDefaults.standard.removeObject(forKey: "VoiceConfidenceThreshold")
    }
    
    /// Returns the current confidence threshold
    func getConfidenceThreshold() -> Float {
        return confidenceThreshold
    }
    
    /// Returns whether voice training is enabled
    func isVoiceTrainingEnabled() -> Bool {
        return voiceTrainingEnabled
    }
}
