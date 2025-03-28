import Foundation

struct VideoSettings {
    var clipDuration: Int // in seconds
    
    static var `default`: VideoSettings {
        return VideoSettings(clipDuration: 10)
    }
}
