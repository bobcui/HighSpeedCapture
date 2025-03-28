import AVFoundation
import UIKit

class VideoPlayerService {
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var looper: AVPlayerLooper?
    
    // MARK: - Playback
    func playVideo(url: URL, in view: UIView, at rate: Float, completion: @escaping () -> Void) {
        // Clean up previous player if it exists
        cleanupPlayer()
        
        // Create player item
        let playerItem = AVPlayerItem(url: url)
        
        // Create a player
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        self.player = queuePlayer
        
        // Setup looper for continuous playback
        looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // Create player layer
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.playerLayer = playerLayer
        
        // Add player layer to view
        view.layer.sublayers?.removeAll(where: { $0 is AVPlayerLayer })
        view.layer.addSublayer(playerLayer)
        
        // Set playback rate to half speed
        queuePlayer.rate = rate
        
        // Start playback
        queuePlayer.play()
        
        // Observe when playback ends (should never be called because of the looper)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            self?.cleanupPlayer()
            completion()
        }
    }
    
    func stopPlayback() {
        cleanupPlayer()
    }
    
    private func cleanupPlayer() {
        // Stop and remove player
        player?.pause()
        player = nil
        
        // Remove looper
        looper = nil
        
        // Remove player layer
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // Remove notification observers
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
}
