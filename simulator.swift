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
class SimulatedApp {
    var videoSettings = VideoSettings.default
    let speechRecognition = SpeechRecognitionSimulator()
    var isVoiceControlEnabled = false
    var isInPlaybackMode = false
    
    func run() {
        print("Current settings: \(videoSettings.clipDuration) seconds clip duration")
        print("Current playback speed: \(videoSettings.playbackSpeed.displayName)")
        print("Voice control: \(isVoiceControlEnabled ? "ON" : "OFF")")
        print("Commands: 'ready' to start recording, 'settings' to change duration")
        print("          'speed' to change playback speed, 'voice' to toggle voice control") 
        print("          'train' to practice voice commands, 'exit' to quit")
        
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
                case "exit":
                    shouldExit = true
                    print("Exiting application...")
                default:
                    if !isVoiceControlEnabled || input != "ready" {
                        print("Unknown command. Try 'ready', 'settings', 'speed', 'voice', 'train', or 'exit'.")
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
        
        print("Recording complete!")
        print("Now playing back at \(videoSettings.playbackSpeed.displayName) in a loop...")
        simulatePlayback()
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
                        print("\nExcellent! You've successfully completed the basic training.")
                        print("Your 'ready' command should now be recognized more reliably.")
                        trainingSession = false
                    } else {
                        print("Success: \(successCount)/\(requiredSuccesses) required")
                    }
                } else if input == "exit" || input == "quit" {
                    print("Training session ended.")
                    trainingSession = false
                } else {
                    // Provide feedback on failed attempt
                    print("✗ Not recognized as 'ready'")
                    
                    // Suggest improvements based on input
                    if input.isEmpty {
                        print("Tip: Make sure your voice is loud enough and clear")
                    } else if input.contains("ready") {
                        print("Tip: You're close! Try to pronounce 'ready' more clearly")
                    } else {
                        print("Tip: Try again, focusing on the 'r' and 'dy' sounds")
                    }
                }
                
                // Check if we've reached max attempts
                if attemptCount >= maxAttempts && successCount < requiredSuccesses {
                    print("\nYou've reached the maximum number of attempts.")
                    print("Let's end this session. You can try again later.")
                    trainingSession = false
                }
            }
        }
        
        // Final feedback
        print("\nTraining session complete!")
        print("You successfully pronounced 'ready' \(successCount) times out of \(attemptCount) attempts")
        
        if successCount >= requiredSuccesses {
            print("Voice recognition has been optimized for your voice pattern")
            // In a real app, we would save the voice profile here
        } else {
            print("Additional practice is recommended to improve recognition accuracy")
        }
        
        print("\nReturning to main menu...")
    }
}

// Run the simulator
let app = SimulatedApp()
app.run()