import Foundation

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