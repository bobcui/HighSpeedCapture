import Foundation

// PlaybackSpeed enum definition
enum PlaybackSpeed: Float, CaseIterable {
    case quarter = 0.25
    case third = 0.33
    case half = 0.5
    case threeQuarters = 0.75
    case normal = 1.0
    
    var displayName: String {
        switch self {
        case .quarter:
            return "1/4 Speed"
        case .third:
            return "1/3 Speed"
        case .half:
            return "1/2 Speed"
        case .threeQuarters:
            return "3/4 Speed"
        case .normal:
            return "Normal Speed"
        }
    }
    
    static var defaultSpeed: PlaybackSpeed {
        return .half
    }
    
    static func fromValue(_ value: Float) -> PlaybackSpeed {
        return PlaybackSpeed.allCases.first { abs($0.rawValue - value) < 0.01 } ?? .half
    }
}

// VideoSettings struct definition
struct VideoSettings {
    var clipDuration: Int // in seconds
    var frameRate: Int = 120 // 120 FPS for slow motion
    var playbackSpeed: PlaybackSpeed = .half // Default to half speed playback
    var qualityPreset: String = "high" // Video quality preset
    
    static var `default`: VideoSettings {
        return VideoSettings(clipDuration: 10)
    }
    
    var playbackSpeedValue: Float {
        return playbackSpeed.rawValue
    }
}

print("SlowMotionVideoApp - 120FPS Video Recorder")
print("===========================================")
print("This is a simulator for the iOS app that can record 120FPS videos")
print("when receiving the instruction like 'ready'.")
print("The time of clips is 10 seconds by default and configurable.")
print("After recording, videos automatically loop playback at customizable speeds")
print("until receiving the record instruction again.")
print("")
print("App Features:")
print("1. Record high frame rate (120FPS) video clips")
print("2. Voice activation with the 'ready' command")
print("3. Configurable clip duration (5-30 seconds)")
print("4. Adjustable playback speeds (1/4, 1/3, 1/2, 3/4, or normal speed)")
print("5. Continuous loop playback until new recording is started")
print("")
print("To run this app on an actual iOS device, build and install using Xcode.")
print("")

// Simulate speech recognition service
class SpeechRecognitionSimulator {
    var isActive = false
    var onCommand: ((String) -> Void)?
    
    func toggleActive() -> Bool {
        isActive = !isActive
        return isActive
    }
    
    func processInput(_ input: String) {
        if isActive && input.lowercased() == "ready" {
            print("Voice command detected: 'ready'")
            onCommand?("ready")
        }
    }
}

// Emulate the app functionality
// Cloud Storage Provider Enum
enum CloudStorageProvider: String, CaseIterable {
    case iCloud = "iCloud"
    case dropbox = "Dropbox"
    case googleDrive = "Google Drive"
    
    var displayName: String {
        return rawValue
    }
}

// Cloud Storage Service
class CloudStorageService {
    private var currentProvider: CloudStorageProvider = .iCloud
    private var isAuthenticated: [CloudStorageProvider: Bool] = [
        .iCloud: false,
        .dropbox: false,
        .googleDrive: false
    ]
    
    func authenticate(provider: CloudStorageProvider, completion: () -> Void) {
        print("Authenticating with \(provider.displayName)...")
        Thread.sleep(forTimeInterval: 1.0)  // Simulate network delay
        isAuthenticated[provider] = true
        print("Successfully authenticated with \(provider.displayName)")
        completion()
    }
    
    func isAuthenticatedWith(provider: CloudStorageProvider) -> Bool {
        return isAuthenticated[provider] ?? false
    }
    
    func uploadVideo(provider: CloudStorageProvider, completion: () -> Void) {
        if !isAuthenticatedWith(provider: provider) {
            print("Error: Not authenticated with \(provider.displayName)")
            return
        }
        
        print("Uploading video to \(provider.displayName)...")
        
        // Simulate upload progress
        for i in 1...5 {
            Thread.sleep(forTimeInterval: 0.5)
            print("Upload progress: \(i * 20)%")
        }
        
        print("Video successfully uploaded to \(provider.displayName)")
        completion()
    }
    
    func shareVideo(provider: CloudStorageProvider, isPublic: Bool, allowComments: Bool, allowDownloads: Bool) -> String {
        let uniqueID = UUID().uuidString.prefix(8)
        var sharingURL = "https://share.\(provider.rawValue.lowercased()).example.com/\(uniqueID)"
        
        // Add query parameters based on options
        var queryParams: [String] = []
        if isPublic {
            queryParams.append("public=true")
        }
        if allowComments {
            queryParams.append("comments=true")
        }
        if allowDownloads {
            queryParams.append("downloads=true")
        }
        
        if !queryParams.isEmpty {
            sharingURL += "?" + queryParams.joined(separator: "&")
        }
        
        return sharingURL
    }
}

class SimulatedApp {
    var videoSettings = VideoSettings.default
    let speechRecognition = SpeechRecognitionSimulator()
    let cloudStorageService = CloudStorageService()
    var isVoiceControlEnabled = false
    var isInPlaybackMode = false
    var hasRecordedVideo = false
    
    func run() {
        print("Current settings: \(videoSettings.clipDuration) seconds clip duration")
        print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
        print("Voice control: \(isVoiceControlEnabled ? "ON" : "OFF")")
        print("Commands: 'ready' to start recording, 'settings' to change duration")
        print("          'speed' to change playback speed, 'voice' to toggle voice control") 
        print("          'train' to practice voice commands, 'cloud' to upload/share")
        print("          'exit' to quit")
        
        // Set up voice command handler
        speechRecognition.onCommand = { [weak self] command in
            if command == "ready" {
                self?.simulateRecording()
            }
        }
        
        var shouldExit = false
        while !shouldExit {
            if let input = readLine()?.lowercased() {
                // Process voice commands if enabled
                if isVoiceControlEnabled {
                    speechRecognition.processInput(input)
                }
                
                // Process direct commands
                switch input {
                case "ready":
                    simulateRecording()
                case "settings":
                    changeSettings()
                case "speed":
                    changePlaybackSpeed()
                case "voice":
                    toggleVoiceControl()
                case "faster", "+":
                    if isInPlaybackMode {
                        cyclePlaybackSpeed()
                    } else {
                        print("Speed control only available during playback.")
                    }
                case "slower", "-":
                    if isInPlaybackMode {
                        previousPlaybackSpeed()
                    } else {
                        print("Speed control only available during playback.")
                    }
                case "train":
                    startVoiceTraining()
                case "cloud":
                    openCloudOptions()
                case "exit":
                    shouldExit = true
                    print("Exiting application...")
                default:
                    if !isVoiceControlEnabled || input != "ready" {
                        print("Unknown command. Try 'ready', 'settings', 'speed', 'voice', 'train', 'cloud', or 'exit'.")
                        if isInPlaybackMode {
                            print("During playback, you can also use 'faster/+' or 'slower/-' to change speed.")
                        }
                    }
                }
            }
        }
    }
    
    private func toggleVoiceControl() {
        isVoiceControlEnabled = speechRecognition.toggleActive()
        print("Voice control is now \(isVoiceControlEnabled ? "ON" : "OFF")")
        if isVoiceControlEnabled {
            print("Say 'ready' to start recording (voice commands will be processed automatically)")
        }
    }
    
    private func simulateRecording() {
        // Exit playback mode if active
        isInPlaybackMode = false
        
        print("Recording started... (will record for \(videoSettings.clipDuration) seconds)")
        
        // Simulate countdown
        for i in (1...videoSettings.clipDuration).reversed() {
            print("\(i) seconds remaining...")
            // In a real app, we'd sleep here, but we'll skip that in the simulation
            Thread.sleep(forTimeInterval: 0.2)  // Speed up the simulation
        }
        
        // Set flag that we have a recorded video
        hasRecordedVideo = true
        
        print("Recording complete!")
        print("Now playing back at \(videoSettings.playbackSpeed.displayName) in a loop...")
        simulatePlayback()
        print("Cloud storage available with 'cloud' command")
        print("(Enter 'ready' to start a new recording)")
    }
    
    private func simulatePlayback() {
        // Simulate looping playback at configured speed
        isInPlaybackMode = true
        
        print("Playback simulation at \(videoSettings.playbackSpeed.displayName) (press Enter to continue):")
        print("Frame 1 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Frame 2 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Frame 3 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Looping playback... (this would continue until a new recording begins)")
        print("Use 'faster/+' or 'slower/-' to adjust playback speed")
    }
    
    private func changeSettings() {
        print("Current clip duration: \(videoSettings.clipDuration) seconds")
        print("Enter new duration (5-30 seconds):")
        
        if let input = readLine(), let newDuration = Int(input) {
            if newDuration >= 5 && newDuration <= 30 {
                videoSettings.clipDuration = newDuration
                print("Duration updated to \(newDuration) seconds")
            } else {
                print("Invalid duration. Please enter a value between 5 and 30.")
            }
        } else {
            print("Invalid input. Please enter a number.")
        }
    }
    
    private func changePlaybackSpeed() {
        print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
        print("Available speeds:")
        
        for (index, speed) in PlaybackSpeed.allCases.enumerated() {
            print("\(index + 1). \(speed.displayName)")
        }
        
        print("Enter number to select speed (1-\(PlaybackSpeed.allCases.count)):")
        
        if let input = readLine(), let speedIndex = Int(input), 
           speedIndex >= 1 && speedIndex <= PlaybackSpeed.allCases.count {
            let newSpeed = PlaybackSpeed.allCases[speedIndex - 1]
            videoSettings.playbackSpeed = newSpeed
            print("Playback speed updated to \(newSpeed.displayName)")
            
            if isInPlaybackMode {
                print("Applied new speed to current playback.")
            }
        } else {
            print("Invalid selection. Please enter a number between 1 and \(PlaybackSpeed.allCases.count).")
        }
    }
    
    private func cyclePlaybackSpeed() {
        // Find the current speed index
        guard let currentIndex = PlaybackSpeed.allCases.firstIndex(of: videoSettings.playbackSpeed) else {
            return
        }
        
        // Get next speed (or cycle back to first)
        let nextIndex = (currentIndex + 1) % PlaybackSpeed.allCases.count
        let nextSpeed = PlaybackSpeed.allCases[nextIndex]
        
        // Set the new speed
        videoSettings.playbackSpeed = nextSpeed
        print("Increased to \(nextSpeed.displayName)")
    }
    
    private func previousPlaybackSpeed() {
        // Find the current speed index
        guard let currentIndex = PlaybackSpeed.allCases.firstIndex(of: videoSettings.playbackSpeed) else {
            return
        }
        
        // Get previous speed (or cycle to last)
        let previousIndex = (currentIndex - 1 + PlaybackSpeed.allCases.count) % PlaybackSpeed.allCases.count
        let previousSpeed = PlaybackSpeed.allCases[previousIndex]
        
        // Set the new speed
        videoSettings.playbackSpeed = previousSpeed
        print("Decreased to \(previousSpeed.displayName)")
    }
    
    // MARK: - Cloud Storage
    private func openCloudOptions() {
        if !hasRecordedVideo {
            print("You need to record a video first before using cloud storage.")
            return
        }
        
        print("=== Cloud Storage & Sharing ===")
        print("Choose a cloud provider:")
        
        // Display provider options
        for (index, provider) in CloudStorageProvider.allCases.enumerated() {
            let authStatus = cloudStorageService.isAuthenticatedWith(provider: provider) ? "✓" : "✗"
            print("\(index + 1). \(provider.displayName) \(authStatus)")
        }
        
        print("\nType a provider number, or 'back' to return:")
        
        if let input = readLine()?.lowercased() {
            if input == "back" {
                return
            }
            
            if let providerIndex = Int(input), 
               providerIndex >= 1 && providerIndex <= CloudStorageProvider.allCases.count {
                
                let selectedProvider = CloudStorageProvider.allCases[providerIndex - 1]
                handleCloudProvider(selectedProvider)
            } else {
                print("Invalid selection. Please enter a number between 1 and \(CloudStorageProvider.allCases.count).")
            }
        }
    }
    
    private func handleCloudProvider(_ provider: CloudStorageProvider) {
        print("\nSelected provider: \(provider.displayName)")
        
        // Check if authenticated
        if !cloudStorageService.isAuthenticatedWith(provider: provider) {
            print("You need to authenticate with \(provider.displayName) first.")
            print("Proceed with authentication? (yes/no)")
            
            if let input = readLine()?.lowercased(), input == "yes" {
                cloudStorageService.authenticate(provider: provider) {
                    self.showCloudProviderOptions(provider)
                }
            }
        } else {
            showCloudProviderOptions(provider)
        }
    }
    
    private func showCloudProviderOptions(_ provider: CloudStorageProvider) {
        print("\n\(provider.displayName) Options:")
        print("1. Upload Video")
        print("2. Share Video")
        print("3. Back to Provider Selection")
        
        if let input = readLine(), let option = Int(input) {
            switch option {
            case 1:
                cloudStorageService.uploadVideo(provider: provider) {
                    self.configureSharing(provider)
                }
            case 2:
                if cloudStorageService.isAuthenticatedWith(provider: provider) {
                    configureSharing(provider)
                } else {
                    print("You need to upload a video first.")
                    cloudStorageService.authenticate(provider: provider) {
                        self.cloudStorageService.uploadVideo(provider: provider) {
                            self.configureSharing(provider)
                        }
                    }
                }
            case 3:
                openCloudOptions()
            default:
                print("Invalid option. Please try again.")
            }
        }
    }
    
    private func configureSharing(_ provider: CloudStorageProvider) {
        var isPublic = false
        var allowComments = true
        var allowDownloads = false
        
        print("\nConfigure Sharing Options:")
        
        print("Make video public? (yes/no) [default: no]")
        if let input = readLine()?.lowercased() {
            isPublic = input == "yes"
        }
        
        print("Allow comments? (yes/no) [default: yes]")
        if let input = readLine()?.lowercased() {
            allowComments = input != "no"
        }
        
        print("Allow downloads? (yes/no) [default: no]")
        if let input = readLine()?.lowercased() {
            allowDownloads = input == "yes"
        }
        
        // Generate sharing URL
        let sharingURL = cloudStorageService.shareVideo(
            provider: provider,
            isPublic: isPublic,
            allowComments: allowComments,
            allowDownloads: allowDownloads
        )
        
        print("\nYour video has been shared!")
        print("Sharing URL: \(sharingURL)")
        print("\nPress Enter to continue...")
        _ = readLine()
    }
    
    // MARK: - Voice Training
    private func startVoiceTraining() {
        print("=== Voice Command Trainer ===")
        print("This trainer will help you improve voice command recognition accuracy")
        print("Let's practice saying the 'ready' command")
        
        var trainingSession = true
        var attemptCount = 0
        var successCount = 0
        
        // Constants for the training session
        let requiredSuccesses = 3
        let maxAttempts = 10
        
        print("\nTraining Tips:")
        print("- Speak clearly and at a moderate pace")
        print("- Keep consistent volume and tone")
        print("- Try different variations if recognition fails")
        print("- Practice in the same environment you'll use the app")
        
        while trainingSession && attemptCount < maxAttempts {
            print("\nAttempt \(attemptCount + 1): Say 'ready' and press Enter")
            
            if let input = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                attemptCount += 1
                
                // Evaluate attempt
                if input == "ready" {
                    successCount += 1
                    print("✓ Success! Good pronunciation.")
                    
                    // Give progress feedback
                    if successCount >= requiredSuccesses {
                        print("\nTraining complete! You've successfully trained the voice recognition.")
                        print("Success rate: \(Float(successCount) / Float(attemptCount) * 100)%")
                        
                        // Update voice control settings
                        isVoiceControlEnabled = true
                        _ = speechRecognition.toggleActive()
                        
                        print("\nVoice control has been enabled based on your training.")
                        trainingSession = false
                    } else {
                        print("Progress: \(successCount)/\(requiredSuccesses) successful attempts")
                    }
                } else {
                    print("✗ Not recognized as 'ready'. Try again with clearer pronunciation.")
                }
                
                // Check if max attempts reached
                if attemptCount >= maxAttempts && successCount < requiredSuccesses {
                    print("\nTraining session ended. You've reached the maximum number of attempts.")
                    print("Success rate: \(Float(successCount) / Float(attemptCount) * 100)%")
                    print("You can try training again later.")
                    trainingSession = false
                }
            }
        }
    }
}

// Run the simulator
let app = SimulatedApp()
app.run()