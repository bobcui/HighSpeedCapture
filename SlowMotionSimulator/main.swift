import Foundation

// PlaybackSpeed enum definition
enum PlaybackSpeed: Float, CaseIterable {
    case quarterSpeed = 0.25
    case halfSpeed = 0.5
    case threeQuarterSpeed = 0.75
    case normalSpeed = 1.0
    case oneAndQuarterSpeed = 1.25
    case oneAndHalfSpeed = 1.5
    case oneAndThreeQuarterSpeed = 1.75
    case doubleSpeed = 2.0
    
    var displayName: String {
        switch self {
        case .quarterSpeed:
            return "0.25x Speed"
        case .halfSpeed:
            return "0.5x Speed"
        case .threeQuarterSpeed:
            return "0.75x Speed"
        case .normalSpeed:
            return "1.0x Speed (Normal)"
        case .oneAndQuarterSpeed:
            return "1.25x Speed"
        case .oneAndHalfSpeed:
            return "1.5x Speed"
        case .oneAndThreeQuarterSpeed:
            return "1.75x Speed"
        case .doubleSpeed:
            return "2.0x Speed"
        }
    }
    
    var isFast: Bool {
        return self.rawValue > 1.0
    }
    
    var isSlow: Bool {
        return self.rawValue < 1.0
    }
    
    static var defaultSpeed: PlaybackSpeed {
        return .halfSpeed
    }
    
    static func fromValue(_ value: Float) -> PlaybackSpeed {
        return PlaybackSpeed.allCases.first { abs($0.rawValue - value) < 0.01 } ?? .halfSpeed
    }
}

// VideoSettings struct definition
struct VideoSettings {
    var clipDuration: Int // in seconds
    var frameRate: Int = 120 // 120 FPS for slow motion
    var playbackSpeed: PlaybackSpeed = .halfSpeed // Default to half speed playback
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
print("4. Adjustable playback speeds (0.25x to 2.0x in 0.25 increments)")
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

// Camera position enum
enum CameraPosition {
    case back
    case front
    
    mutating func toggle() {
        self = self == .back ? .front : .back
    }
    
    var description: String {
        return self == .back ? "Back Camera" : "Front Camera"
    }
}

class SimulatedApp {
    // Main app state
    var videoSettings = VideoSettings.default
    let speechRecognition = SpeechRecognitionSimulator()
    let cloudStorageService = CloudStorageService()
    var isVoiceControlEnabled = false
    var isInPlaybackMode = false
    var hasRecordedVideo = false
    var currentCameraPosition: CameraPosition = .back
    
    // Cached settings for future use
    private var savedSettings: [String: Any] = [
        "clipDuration": 10,
        "playbackSpeed": 0.5
    ]
    
    // Load saved settings if available
    private func loadSavedSettings() {
        if let duration = savedSettings["clipDuration"] as? Int {
            videoSettings.clipDuration = duration
        }
        
        if let speed = savedSettings["playbackSpeed"] as? Float {
            videoSettings.playbackSpeed = PlaybackSpeed.fromValue(speed)
        }
    }
    
    // Save settings for persistence
    private func saveSettings() {
        savedSettings["clipDuration"] = videoSettings.clipDuration
        savedSettings["playbackSpeed"] = videoSettings.playbackSpeed.rawValue
        
        // Display confirmation to user
        print("Settings saved successfully!")
    }
    
    func run() {
        // Load any saved settings first
        loadSavedSettings()
        
        print("Current settings: \(videoSettings.clipDuration) seconds clip duration")
        print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
        print("Voice control: \(isVoiceControlEnabled ? "ON" : "OFF")")
        print("Camera: \(currentCameraPosition.description)")
        print("Commands: 'ready' to start recording, 'settings' to change duration")
        print("          'speed' to change playback speed, 'voice' to toggle voice control") 
        print("          'train' to practice voice commands, 'cloud' to upload/share")
        print("          'switch' to toggle between front and back cameras")
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
                case "switch":
                    switchCamera()
                case "exit":
                    shouldExit = true
                    print("Exiting application...")
                default:
                    if !isVoiceControlEnabled || input != "ready" {
                        print("Unknown command. Try 'ready', 'settings', 'speed', 'voice', 'train', 'cloud', 'switch', or 'exit'.")
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
        
        print("=== 📹 RECORDING IN PROGRESS 📹 ===")
        print("Recording time bar: [          ] 0%")
        
        // Add a message specific to the current camera position
        if currentCameraPosition == .front {
            print("Recording started using \(currentCameraPosition.description)... (will record for \(videoSettings.clipDuration) seconds)")
            print("Capturing 120FPS front-camera video - great for slow-motion selfie videos!")
        } else {
            print("Recording started using \(currentCameraPosition.description)... (will record for \(videoSettings.clipDuration) seconds)")
            print("Capturing 120FPS high-quality video with main camera")
        }
        
        // Simulate countdown with progress bar
        let totalDuration = videoSettings.clipDuration
        for i in (1...totalDuration).reversed() {
            let percentage = 100 - Int(Double(i) / Double(totalDuration) * 100.0)
            let progressBarWidth = 10
            let filledBlocks = Int(Double(progressBarWidth) * Double(percentage) / 100.0)
            let emptyBlocks = progressBarWidth - filledBlocks
            let progressBar = String(repeating: "█", count: filledBlocks) + String(repeating: " ", count: emptyBlocks)
            
            print("\r\u{1B}[2K\(i) seconds remaining... Recording time bar: [\(progressBar)] \(percentage)%", terminator: "")
            fflush(stdout)
            Thread.sleep(forTimeInterval: 0.2)  // Speed up the simulation
            print("")  // Add a newline for each step in the simulator
        }
        
        // Set flag that we have a recorded video
        hasRecordedVideo = true
        
        print("\n=== RECORDING COMPLETE ===")
        print("Now playing back at \(videoSettings.playbackSpeed.displayName) in a loop...")
        simulatePlayback()
        print("Cloud storage available with 'cloud' command")
        print("(Enter 'ready' to start a new recording)")
        print("(Enter 'switch' to change to \(currentCameraPosition == .front ? "back" : "front") camera)")
    }
    
    private func simulatePlayback() {
        // Simulate looping playback at configured speed
        isInPlaybackMode = true
        
        print("\n=== 🔄 REPLAYING VIDEO 🔄 ===")
        print("Playback Speed: \(videoSettings.playbackSpeed.displayName)")
        
        let speedEffect: String
        if videoSettings.playbackSpeed.isSlow {
            speedEffect = "slow motion"
        } else if videoSettings.playbackSpeed.isFast {
            speedEffect = "fast motion"
        } else {
            speedEffect = "normal speed"
        }
        
        // Show playback progress bar
        let progressBarWidth = 20
        
        print("Playback simulation at \(videoSettings.playbackSpeed.displayName) (press Enter to continue):")
        
        // Simulate first loop with visual feedback
        for i in 1...10 {
            let percentage = i * 10
            let filledBlocks = Int(Double(progressBarWidth) * Double(percentage) / 100.0)
            let emptyBlocks = progressBarWidth - filledBlocks
            let progressBar = String(repeating: "▶", count: filledBlocks) + String(repeating: "·", count: emptyBlocks)
            
            print("\rPlayback progress: [\(progressBar)] \(percentage)% - Frame \(i) (\(speedEffect))...", terminator: "")
            fflush(stdout)
            Thread.sleep(forTimeInterval: 0.2)
        }
        
        print("\n\n=== LOOPING PLAYBACK ===")
        print("Video will continue playing in a loop until a new recording begins")
        print("Use 'faster/+' or 'slower/-' to adjust playback speed (0.25x to 2.0x)")
    }
    
    private func changeSettings() {
        print("Current clip duration: \(videoSettings.clipDuration) seconds")
        print("Enter new duration (5-30 seconds):")
        
        if let input = readLine(), let newDuration = Int(input) {
            if newDuration >= 5 && newDuration <= 30 {
                videoSettings.clipDuration = newDuration
                print("Duration updated to \(newDuration) seconds")
                
                // Save the new duration to persistent settings
                saveSettings()
                print("This setting will be preserved for future recordings.")
                
                // Update the main app display
                print("\nCurrent settings: \(videoSettings.clipDuration) seconds clip duration")
                print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
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
            
            // Save the new speed to persistent settings
            saveSettings()
            print("This setting will be preserved for future recordings.")
            
            // Update the main app display
            print("\nCurrent settings: \(videoSettings.clipDuration) seconds clip duration")
            print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
            
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
        
        // Save the setting
        saveSettings()
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
        
        // Save the setting
        saveSettings()
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
    
    // MARK: - Camera Control
    /**
     * Handles switching between front and back cameras
     * 
     * This method:
     * 1. Toggles the current camera position
     * 2. Shows a loading message
     * 3. Simulates the camera switching process
     * 4. Updates with current camera status
     *
     * In a real device, this would reconfigure the camera session.
     */
    private func switchCamera() {
        // Don't allow switching during recording or playback
        if isInPlaybackMode {
            print("Cannot switch cameras during playback. Exit playback mode first.")
            return
        }
        
        print("Switching camera...")
        
        // Simulate camera switching delay
        Thread.sleep(forTimeInterval: 0.5)
        
        // Toggle camera position
        currentCameraPosition.toggle()
        
        // Simulate camera initialization
        for i in 1...3 {
            print("Initializing camera... \(i*33)%")
            Thread.sleep(forTimeInterval: 0.3)
        }
        
        print("Camera switched to \(currentCameraPosition.description)")
        
        // Provide additional info based on camera
        if currentCameraPosition == .front {
            print("Front camera activated - perfect for selfie videos")
            print("120FPS recording maintained for high-quality slow-motion selfies")
        } else {
            print("Back camera activated - using high frame rate mode")
            print("Optimal settings applied for 120FPS slow-motion recording")
        }
        
        print("Ready to record from \(currentCameraPosition.description). Enter 'ready' to start.") 
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