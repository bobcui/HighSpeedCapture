# SlowMotionVideoApp

An advanced iOS application for high-frame-rate video recording with intelligent interaction and enhanced sharing capabilities.

## Project Description

SlowMotionVideoApp is designed to record high-quality 120FPS videos that can be activated by a voice command ("ready"). The app allows users to configure recording duration (default 10 seconds) and automatically loops recorded videos with customizable playback speeds (default half-speed) until receiving another record instruction. It includes a voice command pronunciation trainer to improve recognition accuracy and comprehensive cloud storage/sharing options for saved videos.

## Key Features

- **High-frame-rate recording** (120FPS) for smooth slow-motion playback
- **Voice-activated recording** using the "ready" command
- **Configurable recording duration** (5-30 seconds)
- **Multiple playback speeds**: 1/4, 1/3, 1/2, 3/4, and normal speed
- **Voice command training** to improve recognition accuracy
- **Cloud storage integration** with multiple providers
- **Comprehensive sharing options** with privacy controls

## Project Structure

```
SlowMotionVideoApp/
├── SlowMotionSimulator/            # Command-line simulator
│   ├── VideoSettings.swift         # Video configuration model
│   └── main.swift                  # Simulator implementation
├── SlowMotionVideoApp/             # iOS app
│   ├── Controllers/                # MVC controllers
│   │   ├── CameraViewController.swift
│   │   ├── CloudStorageViewController.swift
│   │   ├── SettingsViewController.swift
│   │   └── VoiceTrainingViewController.swift
│   ├── Models/                     # Data models
│   │   └── VideoSettings.swift
│   ├── Services/                   # Service layer
│   │   ├── CameraService.swift
│   │   ├── CloudStorageService.swift
│   │   ├── SpeechRecognitionService.swift
│   │   └── VideoPlayerService.swift
│   ├── Views/                      # UI components
│   │   └── CameraControlsView.swift
│   ├── Resources/                  # App resources
│   │   └── Assets.xcassets
│   ├── AppDelegate.swift           # App entry point
│   ├── SceneDelegate.swift         # Scene configuration
│   └── Info.plist                  # App information
├── functionality_overview.md       # Detailed feature documentation
├── simulator.swift                 # Alternative simulator implementation
└── Package.swift                   # Swift package definition
```

## Getting Started

### Using the CLI Simulator

The CLI simulator allows you to test the core functionality of the app without needing an iOS device:

1. Run the simulator:
   ```
   swift SlowMotionSimulator/main.swift
   ```

2. Available commands:
   - `ready`: Start recording
   - `settings`: Change recording duration
   - `speed`: Change playback speed
   - `voice`: Toggle voice control
   - `train`: Practice voice commands
   - `cloud`: Upload/share videos
   - `exit`: Quit the simulator

### Real App Deployment

To build and deploy the full iOS app:

1. Open the project in Xcode
2. Set up provisioning profiles and signing
3. Build and run on an iOS device

## Technologies Used

- **Swift** programming language
- **iOS** development framework
- **Core Video** and **AVFoundation** for video processing
- **Speech Recognition** APIs for voice commands
- **Cloud Storage** APIs for sharing functionality

## Future Enhancements

- Video filters and effects
- Background music options
- Enhanced social sharing integration
- Analytics for video performance
- Multi-camera support

## See Also

- [Functionality Overview](functionality_overview.md) - Detailed feature documentation