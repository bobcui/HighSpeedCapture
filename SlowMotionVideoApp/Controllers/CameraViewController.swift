import UIKit
import AVFoundation
import Speech

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    private let cameraService = CameraService()
    private let videoPlayerService = VideoPlayerService()
    private let speechRecognitionService = SpeechRecognitionService()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var playerLayer: AVPlayerLayer?
    private var currentRecordingURL: URL?
    
    private var recordingTimer: Timer?
    private var recordingTimeSeconds: Int = 0
    private var isShowingRecordingUI = true
    private var isSpeechRecognitionActive = false
    
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
    
    private lazy var voiceControlButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(voiceControlButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var voiceTrainingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "waveform"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(voiceTrainingButtonTapped), for: .touchUpInside)
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
    
    private lazy var speedControlView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.text = "1/2 Speed"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var speedSlowerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(speedSlowerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var speedFasterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(speedFasterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var voiceStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Voice: Off"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCamera()
        setupSpeechRecognition()
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
        if isSpeechRecognitionActive {
            speechRecognitionService.stopListening()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(previewView)
        view.addSubview(recordButton)
        view.addSubview(settingsButton)
        view.addSubview(voiceControlButton)
        view.addSubview(voiceTrainingButton)
        view.addSubview(timeLabel)
        view.addSubview(recordingIndicator)
        view.addSubview(playbackControlButton)
        view.addSubview(voiceStatusLabel)
        
        // Setup speed control UI
        setupSpeedControlUI()
        
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
            
            // Voice control button
            voiceControlButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            voiceControlButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            voiceControlButton.widthAnchor.constraint(equalToConstant: 44),
            voiceControlButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Voice training button
            voiceTrainingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            voiceTrainingButton.leadingAnchor.constraint(equalTo: voiceControlButton.trailingAnchor, constant: 15),
            voiceTrainingButton.widthAnchor.constraint(equalToConstant: 44),
            voiceTrainingButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Voice status label
            voiceStatusLabel.topAnchor.constraint(equalTo: voiceControlButton.bottomAnchor, constant: 5),
            voiceStatusLabel.centerXAnchor.constraint(equalTo: voiceControlButton.centerXAnchor),
            
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
    
    private func setupSpeedControlUI() {
        // Add speed control to view
        view.addSubview(speedControlView)
        speedControlView.addSubview(speedSlowerButton)
        speedControlView.addSubview(speedLabel)
        speedControlView.addSubview(speedFasterButton)
        
        NSLayoutConstraint.activate([
            // Speed control view
            speedControlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            speedControlView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            speedControlView.heightAnchor.constraint(equalToConstant: 44),
            speedControlView.widthAnchor.constraint(equalToConstant: 180),
            
            // Speed slower button
            speedSlowerButton.leadingAnchor.constraint(equalTo: speedControlView.leadingAnchor, constant: 12),
            speedSlowerButton.centerYAnchor.constraint(equalTo: speedControlView.centerYAnchor),
            speedSlowerButton.widthAnchor.constraint(equalToConstant: 30),
            speedSlowerButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Speed label
            speedLabel.centerYAnchor.constraint(equalTo: speedControlView.centerYAnchor),
            speedLabel.centerXAnchor.constraint(equalTo: speedControlView.centerXAnchor),
            speedLabel.widthAnchor.constraint(equalToConstant: 80),
            
            // Speed faster button
            speedFasterButton.trailingAnchor.constraint(equalTo: speedControlView.trailingAnchor, constant: -12),
            speedFasterButton.centerYAnchor.constraint(equalTo: speedControlView.centerYAnchor),
            speedFasterButton.widthAnchor.constraint(equalToConstant: 30),
            speedFasterButton.heightAnchor.constraint(equalToConstant: 30)
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
    
    private func setupSpeechRecognition() {
        // Set up speech recognition delegate
        speechRecognitionService.delegate = self
        
        // Request authorization
        speechRecognitionService.requestAuthorization { [weak self] authorized in
            guard let self = self else { return }
            
            if !authorized {
                self.showAlert(title: "Speech Recognition", message: "Speech recognition permission is required for voice commands. Please enable it in Settings.")
            }
        }
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
    
    @objc private func voiceControlButtonTapped() {
        toggleSpeechRecognition()
    }
    
    @objc private func voiceTrainingButtonTapped() {
        // Present the voice training view controller
        let trainingVC = VoiceTrainingViewController()
        trainingVC.delegate = self
        trainingVC.modalPresentationStyle = .fullScreen
        present(trainingVC, animated: true)
    }
    
    private func toggleSpeechRecognition() {
        if isSpeechRecognitionActive {
            // Turn off speech recognition
            speechRecognitionService.stopListening()
            isSpeechRecognitionActive = false
            voiceControlButton.tintColor = .white
            voiceStatusLabel.text = "Voice: Off"
        } else {
            // Turn on speech recognition
            do {
                try speechRecognitionService.startListening()
                isSpeechRecognitionActive = true
                voiceControlButton.tintColor = .systemBlue
                voiceStatusLabel.text = "Voice: On"
            } catch {
                showAlert(title: "Speech Recognition Error", message: error.localizedDescription)
            }
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
            // Setup player and set delegate
            videoPlayerService.delegate = self
            let playerLayer = try videoPlayerService.setupPlayer(with: url, in: previewView)
            self.playerLayer = playerLayer
            previewView.layer.addSublayer(playerLayer)
            
            // Show playback UI
            playbackControlButton.isHidden = false
            speedControlView.isHidden = false
            
            // Update speed label
            speedLabel.text = videoPlayerService.currentPlaybackSpeed.displayName
            
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
    
    @objc private func speedFasterButtonTapped() {
        videoPlayerService.cyclePlaybackSpeed()
    }
    
    @objc private func speedSlowerButtonTapped() {
        videoPlayerService.previousPlaybackSpeed()
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
        speedControlView.isHidden = true
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

// MARK: - VideoPlayerDelegate
extension CameraViewController: VideoPlayerDelegate {
    func playerDidUpdatePlaybackSpeed(_ speed: PlaybackSpeed) {
        // Update the label with the new speed
        speedLabel.text = speed.displayName
        
        // Add animation feedback for speed change
        UIView.animate(withDuration: 0.2, animations: {
            self.speedLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.speedLabel.transform = .identity
            }
        }
    }
}

// MARK: - SpeechRecognitionDelegate
extension CameraViewController: SpeechRecognitionDelegate {
    func speechRecognitionDidDetectCommand(_ command: String) {
        print("Voice command detected: \(command)")
        
        // Handle "ready" command
        if command.lowercased() == "ready" && !cameraService.isRecording {
            DispatchQueue.main.async {
                // Visual feedback that voice command was received
                UIView.animate(withDuration: 0.3, animations: {
                    self.recordButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.recordButton.transform = .identity
                    }
                }
                
                // Start recording
                self.startRecording()
            }
        }
    }
}

// MARK: - VoiceTrainingViewControllerDelegate
extension CameraViewController: VoiceTrainingViewControllerDelegate {
    func voiceTrainingDidComplete(with confidence: Float) {
        // Update the speech recognition service with the new voice profile
        speechRecognitionService.updateVoiceProfile(for: "ready", with: confidence)
        
        // Give visual feedback that training was successful
        if confidence > 0.6 {
            voiceTrainingButton.tintColor = .systemGreen
            
            // Show a success message
            let message = String(format: "Voice training completed successfully with %.0f%% confidence", confidence * 100)
            let alert = UIAlertController(title: "Training Complete", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else if confidence > 0.0 {
            voiceTrainingButton.tintColor = .systemYellow
            
            // Show a partial success message
            let message = "Voice training completed with moderate success. Additional training is recommended."
            let alert = UIAlertController(title: "Training Partial Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}