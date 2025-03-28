import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - Properties
    private let cameraService = CameraService()
    private let videoPlayerService = VideoPlayerService()
    private var videoSettings = VideoSettings.default
    
    private var isRecording = false
    private var isPlayingBack = false
    
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
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to Record"
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCameraService()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isRecording {
            stopRecording()
        }
        cameraService.stopSession()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(previewView)
        view.addSubview(recordButton)
        view.addSubview(settingsButton)
        view.addSubview(statusLabel)
        view.addSubview(countdownLabel)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 60),
            recordButton.heightAnchor.constraint(equalToConstant: 60),
            
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            settingsButton.widthAnchor.constraint(equalToConstant: 80),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 40),
            
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 120),
            countdownLabel.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupNavigationBar() {
        title = "120FPS Video Recorder"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupCameraService() {
        // Setup camera preview layer
        cameraService.prepareCamera(frameRate: 120) { [weak self] success in
            guard let self = self else { return }
            if success {
                if let previewLayer = self.cameraService.previewLayer {
                    previewLayer.frame = self.previewView.bounds
                    self.previewView.layer.addSublayer(previewLayer)
                }
                self.cameraService.startSession()
            } else {
                self.showAlert(title: "Camera Error", message: "Unable to access camera with required specifications.")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func recordButtonTapped() {
        if isPlayingBack {
            // Stop playback and start recording
            videoPlayerService.stopPlayback()
            isPlayingBack = false
            startRecording()
        } else if isRecording {
            // Already recording, ignore
            return
        } else {
            // Start new recording
            startRecording()
        }
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.videoSettings = videoSettings
        settingsVC.delegate = self
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    // MARK: - Recording Functions
    private func startRecording() {
        updateUI(forRecording: true)
        
        cameraService.startRecording(duration: videoSettings.clipDuration) { [weak self] success, fileURL in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.updateUI(forRecording: false)
                
                if success, let url = fileURL {
                    self.playRecordedVideo(url: url)
                } else {
                    self.showAlert(title: "Recording Error", message: "Failed to record video.")
                }
            }
        }
        
        startCountdown(duration: videoSettings.clipDuration)
    }
    
    private func stopRecording() {
        cameraService.stopRecording()
        updateUI(forRecording: false)
    }
    
    private func playRecordedVideo(url: URL) {
        isPlayingBack = true
        statusLabel.text = "Playing back at 1/2 speed"
        
        // Setup player in the preview view
        videoPlayerService.playVideo(url: url, in: previewView, at: 0.5) { [weak self] in
            // This is called when playback ends
            // Since we're looping, this won't be called unless an error occurs
            self?.isPlayingBack = false
            self?.statusLabel.text = "Ready to Record"
        }
    }
    
    private func updateUI(forRecording: Bool) {
        isRecording = forRecording
        recordButton.setTitle(forRecording ? "Recording..." : "Ready", for: .normal)
        recordButton.backgroundColor = forRecording ? .systemRed.withAlphaComponent(0.7) : .systemRed
        statusLabel.text = forRecording ? "Recording in progress..." : "Ready to Record"
        settingsButton.isEnabled = !forRecording
    }
    
    private func startCountdown(duration: Int) {
        countdownLabel.isHidden = false
        var secondsLeft = duration
        
        func updateCountdown() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.countdownLabel.text = "\(secondsLeft)"
                secondsLeft -= 1
                
                if secondsLeft < 0 {
                    self.countdownLabel.isHidden = true
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    updateCountdown()
                }
            }
        }
        
        updateCountdown()
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SettingsViewControllerDelegate
extension CameraViewController: SettingsViewControllerDelegate {
    func didUpdateSettings(_ settings: VideoSettings) {
        self.videoSettings = settings
    }
}
