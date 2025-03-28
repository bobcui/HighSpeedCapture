import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private var videoSettings: VideoSettings
    
    // MARK: - UI Elements
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Recording Duration (seconds):"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 30
        slider.value = Float(videoSettings.clipDuration)
        slider.addTarget(self, action: #selector(durationSliderChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var durationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "\(videoSettings.clipDuration)"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playbackSpeedLabel: UILabel = {
        let label = UILabel()
        label.text = "Playback Speed:"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var playbackSpeedSegmentedControl: UISegmentedControl = {
        // Create items from PlaybackSpeed enum display names
        let items = PlaybackSpeed.allCases.map { $0.displayName }
        let segmentedControl = UISegmentedControl(items: items)
        
        // Set default segment based on current settings
        if let index = PlaybackSpeed.allCases.firstIndex(of: videoSettings.playbackSpeed) {
            segmentedControl.selectedSegmentIndex = index
        } else {
            segmentedControl.selectedSegmentIndex = PlaybackSpeed.allCases.firstIndex(of: .half) ?? 0
        }
        
        segmentedControl.addTarget(self, action: #selector(playbackSpeedChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    init(videoSettings: VideoSettings) {
        self.videoSettings = videoSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        
        // Add subviews
        view.addSubview(durationLabel)
        view.addSubview(durationSlider)
        view.addSubview(durationValueLabel)
        view.addSubview(playbackSpeedLabel)
        view.addSubview(playbackSpeedSegmentedControl)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Duration label
            durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Duration slider
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            durationSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            durationSlider.trailingAnchor.constraint(equalTo: durationValueLabel.leadingAnchor, constant: -20),
            
            // Duration value label
            durationValueLabel.centerYAnchor.constraint(equalTo: durationSlider.centerYAnchor),
            durationValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            durationValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // Playback speed label
            playbackSpeedLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 30),
            playbackSpeedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // Playback speed segmented control
            playbackSpeedSegmentedControl.topAnchor.constraint(equalTo: playbackSpeedLabel.bottomAnchor, constant: 10),
            playbackSpeedSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playbackSpeedSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Save button
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -10),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func durationSliderChanged(_ sender: UISlider) {
        let roundedValue = Int(sender.value)
        durationValueLabel.text = "\(roundedValue)"
        videoSettings.clipDuration = roundedValue
    }
    
    @objc private func playbackSpeedChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex >= 0 && sender.selectedSegmentIndex < PlaybackSpeed.allCases.count {
            videoSettings.playbackSpeed = PlaybackSpeed.allCases[sender.selectedSegmentIndex]
        } else {
            videoSettings.playbackSpeed = .half // Default to half speed
        }
    }
    
    @objc private func saveButtonTapped() {
        // Notify parent that settings were saved
        // (In a real app, you would use a delegate pattern or a notification to update the parent's settings)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        // Dismiss without saving
        dismiss(animated: true, completion: nil)
    }
}