import Foundation
import AVFoundation
import UIKit

enum PlayerError: Error {
    case invalidVideoURL
    case playerFailedToInitialize
    case playerItemFailedToLoad
}

class VideoPlayerService {
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    private var looper: AVPlayerLooper?
    private var playerItem: AVPlayerItem?
    
    var isPlaying: Bool {
        return player?.rate != 0
    }
    
    var currentTime: CMTime? {
        return player?.currentTime()
    }
    
    var duration: CMTime? {
        return player?.currentItem?.duration
    }
    
    let videoSettings: VideoSettings
    
    // MARK: - Init
    init(videoSettings: VideoSettings = .default) {
        self.videoSettings = videoSettings
    }
    
    deinit {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Player Setup
    func setupPlayer(with url: URL, in view: UIView) throws -> AVPlayerLayer {
        // Create player item
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        
        // Apply slow motion by changing rate
        playerItem.audioTimePitchAlgorithm = .spectral  // Maintain audio pitch during slow playback
        
        // Create player with the item
        let player = AVQueuePlayer(playerItem: playerItem)
        player.rate = videoSettings.playbackSpeed  // Set to play at half speed
        self.player = player
        
        // Create player looper
        self.looper = AVPlayerLooper(player: player as! AVQueuePlayer, templateItem: playerItem)
        
        // Create and configure layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        self.playerLayer = playerLayer
        
        // Add time observer
        addPeriodicTimeObserver()
        
        // Add notification observers
        setupObservers()
        
        return playerLayer
    }
    
    private func setupObservers() {
        // Observe when playback ends
        NotificationCenter.default.addObserver(self, 
                                              selector: #selector(playerItemDidReachEnd),
                                              name: .AVPlayerItemDidPlayToEndTime,
                                              object: player?.currentItem)
        
        // Observe when app enters background
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(appDidEnterBackground),
                                              name: UIApplication.didEnterBackgroundNotification,
                                              object: nil)
        
        // Observe when app enters foreground
        NotificationCenter.default.addObserver(self,
                                              selector: #selector(appWillEnterForeground),
                                              name: UIApplication.willEnterForegroundNotification,
                                              object: nil)
    }
    
    // MARK: - Player Control
    func play() {
        player?.play()
        player?.rate = videoSettings.playbackSpeed
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func clearPlayer() {
        pause()
        removeTimeObserver()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
    }
    
    // MARK: - Time Observation
    private func addPeriodicTimeObserver() {
        // Observe time at 0.5 second intervals
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            // Handle time observation
        }
    }
    
    private func removeTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // MARK: - Notification Handlers
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // In a loop player, we don't need to handle end differently
    }
    
    @objc private func appDidEnterBackground(_ notification: Notification) {
        // Pause playback when app enters background
        pause()
    }
    
    @objc private func appWillEnterForeground(_ notification: Notification) {
        // Resume playback when app enters foreground
        play()
    }
}