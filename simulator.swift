import Foundation

struct VideoSettings {
    var clipDuration: Int // in seconds
    var frameRate: Int = 120 // 120 FPS for slow motion
    var playbackSpeed: Float = 0.5 // Half speed playback
    var qualityPreset: String = "high" // Video quality preset
    
    static var `default`: VideoSettings {
        return VideoSettings(clipDuration: 10)
    }
}

print("SlowMotionVideoApp - 120FPS Video Recorder")
print("===========================================")
print("This is a simulator for the iOS app that can record 120FPS videos")
print("when receiving the instruction like 'ready'.")
print("The time of clips is 10 seconds by default and configurable.")
print("After recording, videos automatically loop playback at 1/2 speed")
print("until receiving the record instruction again.")
print("")
print("App Features:")
print("1. Record high frame rate (120FPS) video clips")
print("2. Voice activation with the 'ready' command")
print("3. Configurable clip duration (5-30 seconds)")
print("4. Automatic playback at half speed for slow motion effect")
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
    
    func run() {
        print("Current settings: \(videoSettings.clipDuration) seconds clip duration")
        print("Voice control: \(isVoiceControlEnabled ? "ON" : "OFF")")
        print("Commands: 'ready' to start recording, 'settings' to change duration")
        print("          'voice' to toggle voice control, 'exit' to quit")
        
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
                case "voice":
                    toggleVoiceControl()
                case "exit":
                    shouldExit = true
                    print("Exiting application...")
                default:
                    if !isVoiceControlEnabled || input != "ready" {
                        print("Unknown command. Try 'ready', 'settings', 'voice', or 'exit'.")
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
        print("Recording started... (will record for \(videoSettings.clipDuration) seconds)")
        
        // Simulate countdown
        for i in (1...videoSettings.clipDuration).reversed() {
            print("\(i) seconds remaining...")
            // In a real app, we'd sleep here, but we'll skip that in the simulation
            Thread.sleep(forTimeInterval: 0.2)  // Speed up the simulation
        }
        
        print("Recording complete!")
        print("Now playing back at 1/2 speed in a loop...")
        simulatePlayback()
        print("(Enter 'ready' to start a new recording)")
    }
    
    private func simulatePlayback() {
        // Simulate looping playback at half speed
        print("Playback simulation (press Enter to continue):")
        print("Frame 1 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Frame 2 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Frame 3 (slow motion)...")
        Thread.sleep(forTimeInterval: 0.5)
        print("Looping playback... (this would continue until a new recording begins)")
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
}

// Run the simulator
let app = SimulatedApp()
app.run()