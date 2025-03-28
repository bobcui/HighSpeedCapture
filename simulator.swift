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
print("2. Configurable clip duration (5-30 seconds)")
print("3. Automatic playback at half speed for slow motion effect")
print("4. Continuous loop playback until new recording is started")
print("")
print("To run this app on an actual iOS device, build and install using Xcode.")
print("")

// Emulate the app functionality
class SimulatedApp {
    var videoSettings = VideoSettings.default
    
    func run() {
        print("Current settings: \(videoSettings.clipDuration) seconds clip duration")
        print("Enter 'ready' to start recording, 'settings' to change duration, or 'exit' to quit:")
        
        var shouldExit = false
        while !shouldExit {
            if let input = readLine()?.lowercased() {
                switch input {
                case "ready":
                    simulateRecording()
                case "settings":
                    changeSettings()
                case "exit":
                    shouldExit = true
                    print("Exiting application...")
                default:
                    print("Unknown command. Try 'ready', 'settings', or 'exit'.")
                }
            }
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