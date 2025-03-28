import UIKit

protocol CameraControlsViewDelegate: AnyObject {
    func didTapRecordButton()
    func didTapSettingsButton()
}

class CameraControlsView: UIView {
    
    // MARK: - Properties
    weak var delegate: CameraControlsViewDelegate?
    
    private var isRecording = false
    
    // MARK: - UI Elements
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
    
    private lazy var recordingIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        // Add subviews
        addSubview(recordButton)
        addSubview(settingsButton)
        addSubview(recordingIndicator)
        addSubview(timeLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Time label
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Recording indicator
            recordingIndicator.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor),
            recordingIndicator.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            recordingIndicator.widthAnchor.constraint(equalToConstant: 10),
            recordingIndicator.heightAnchor.constraint(equalToConstant: 10)
        ])
    }
    
    // MARK: - Actions
    @objc private func recordButtonTapped() {
        delegate?.didTapRecordButton()
    }
    
    @objc private func settingsButtonTapped() {
        delegate?.didTapSettingsButton()
    }
    
    // MARK: - Public Methods
    func updateForRecordingState(_ isRecording: Bool) {
        self.isRecording = isRecording
        
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
    
    func updateTimeLabel(minutes: Int, seconds: Int) {
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func showControls(_ show: Bool) {
        recordButton.isHidden = !show
        settingsButton.isHidden = !show
        timeLabel.isHidden = !show
        recordingIndicator.isHidden = !show || !isRecording
    }
}