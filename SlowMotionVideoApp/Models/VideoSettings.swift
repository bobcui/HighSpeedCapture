import Foundation

enum PlaybackSpeed: Float, CaseIterable {
    case quarter = 0.25
    case third = 0.33
    case half = 0.5
    case threeQuarters = 0.75
    case normal = 1.0
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case oneAndThreeQuarters = 1.75
    case double = 2.0
    
    var displayName: String {
        switch self {
        case .quarter:
            return "0.25x Speed"
        case .third:
            return "0.33x Speed"
        case .half:
            return "0.5x Speed"
        case .threeQuarters:
            return "0.75x Speed"
        case .normal:
            return "1.0x Speed"
        case .oneAndQuarter:
            return "1.25x Speed"
        case .oneAndHalf:
            return "1.5x Speed"
        case .oneAndThreeQuarters:
            return "1.75x Speed"
        case .double:
            return "2.0x Speed"
        }
    }
    
    var isFastForward: Bool {
        return self.rawValue > 1.0
    }
    
    var isSlowMotion: Bool {
        return self.rawValue < 1.0
    }
    
    static var defaultSpeed: PlaybackSpeed {
        return .half
    }
    
    static func fromValue(_ value: Float) -> PlaybackSpeed {
        return PlaybackSpeed.allCases.first { abs($0.rawValue - value) < 0.01 } ?? .half
    }
}

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