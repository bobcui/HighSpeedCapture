import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    private let cameraService = CameraService()
    private let videoPlayerService = VideoPlayerService()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var playerLayer: AVPlayerLayer?
    private var currentRecordingURL: URL?
    
    private var recordingTimer: Timer?
    private var recordingTimeSeconds: Int = 0
    private var isShowingRecordingUI = true
    
    // MARK: - UI Elements
    private lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ready", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var recordingIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playbackControlButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playbackControlButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = previewView.bounds
        playerLayer?.frame = previewView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraService.stopSession()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(previewView)
        view.addSubview(recordButton)
        view.addSubview(settingsButton)
        view.addSubview(timeLabel)
        view.addSubview(recordingIndicator)
        view.addSubview(playbackControlButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Preview view
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
            previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Time label
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Recording indicator
            recordingIndicator.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            recordingIndicator.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            recordingIndicator.widthAnchor.constraint(equalToConstant: 10),
            recordingIndicator.heightAnchor.constraint(equalToConstant: 10),
            
            // Playback control
            playbackControlButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playbackControlButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playbackControlButton.widthAnchor.constraint(equalToConstant: 60),
            playbackControlButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCamera() {
        // Check camera permissions
        let isAuthorized = cameraService.checkPermissions()
        
        if isAuthorized {
            configureCamera()
        }
        
        // Set up video output delegate
        cameraService.delegate = self
    }
    
    private func configureCamera() {
        do {
            try cameraService.setupCamera()
            guard let session = cameraService.session else {
                print("Failed to get capture session")
                return
            }
            
            // Set up preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = previewView.bounds
            
            previewView.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
            
            // Start session
            cameraService.startSession()
        } catch {
            showAlert(title: "Camera Error", message: "Failed to setup camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Recording
    @objc private func recordButtonTapped() {
        if cameraService.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        cameraService.startRecording { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Recording Error", message: error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.updateUIForRecording(true)
                self.startRecordingTimer()
            }
        }
    }
    
    private func stopRecording() {
        cameraService.stopRecording { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Recording Error", message: error.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.updateUIForRecording(false)
                self.stopRecordingTimer()
                
                // Transition to playback if we have a recent recording
                if let lastClip = self.cameraService.recordedClips.last {
                    self.showPlayback(for: lastClip)
                }
            }
        }
    }
    
    private func updateUIForRecording(_ isRecording: Bool) {
        if isRecording {
            recordButton.setTitle("Stop", for: .normal)
            recordingIndicator.isHidden = false
            // Start recording indicator animation
            UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.recordingIndicator.alpha = 0.3
            })
        } else {
            recordButton.setTitle("Ready", for: .normal)
            recordingIndicator.isHidden = true
            recordingIndicator.alpha = 1.0
            recordingIndicator.layer.removeAllAnimations()
        }
    }
    
    // MARK: - Playback
    private func showPlayback(for url: URL) {
        currentRecordingURL = url
        
        // Hide camera UI
        previewLayer?.isHidden = true
        recordButton.isHidden = true
        isShowingRecordingUI = false
        
        do {
            // Setup player
            let playerLayer = try videoPlayerService.setupPlayer(with: url, in: previewView)
            self.playerLayer = playerLayer
            previewView.layer.addSublayer(playerLayer)
            
            // Show playback UI
            playbackControlButton.isHidden = false
            
            // Start playback
            videoPlayerService.play()
        } catch {
            showAlert(title: "Playback Error", message: error.localizedDescription)
            resetToCamera()
        }
    }
    
    @objc private func playbackControlButtonTapped() {
        videoPlayerService.togglePlayback()
        
        // Update button icon
        let symbolName = videoPlayerService.isPlaying ? "pause.fill" : "play.fill"
        playbackControlButton.setImage(UIImage(systemName: symbolName), for: .normal)
    }
    
    private func resetToCamera() {
        // Clear player
        videoPlayerService.clearPlayer()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // Show camera UI
        previewLayer?.isHidden = false
        recordButton.isHidden = false
        playbackControlButton.isHidden = true
        isShowingRecordingUI = true
    }
    
    // MARK: - Recording Timer
    private func startRecordingTimer() {
        recordingTimeSeconds = 0
        updateTimeLabel()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTimeSeconds += 1
            self.updateTimeLabel()
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingTimeSeconds = 0
        updateTimeLabel()
    }
    
    private func updateTimeLabel() {
        let minutes = recordingTimeSeconds / 60
        let seconds = recordingTimeSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Settings
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController(videoSettings: cameraService.videoSettings)
        present(settingsVC, animated: true)
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
            return
        }
        
        // Add the recorded clip to our list
        cameraService.recordedClips.append(outputFileURL)
        currentRecordingURL = outputFileURL
        
        // Stop recording UI and show playback
        DispatchQueue.main.async {
            self.stopRecording()
        }
    }
}