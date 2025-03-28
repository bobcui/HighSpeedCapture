import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func didUpdateSettings(_ settings: VideoSettings)
}

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    var videoSettings = VideoSettings.default
    weak var delegate: SettingsViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Clip Duration (seconds)"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 30
        slider.value = Float(videoSettings.clipDuration)
        slider.addTarget(self, action: #selector(durationSliderChanged), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var durationValueLabel: UILabel = {
        let label = UILabel()
        label.text = "\(videoSettings.clipDuration)"
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "This app records videos at 120 FPS and automatically plays them back at half speed in a loop."
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .black
        
        view.addSubview(durationLabel)
        view.addSubview(durationSlider)
        view.addSubview(durationValueLabel)
        view.addSubview(infoLabel)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            durationValueLabel.topAnchor.constraint(equalTo: durationLabel.topAnchor),
            durationValueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            durationValueLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 10),
            durationValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            durationSlider.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            durationSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            durationSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoLabel.topAnchor.constraint(equalTo: durationSlider.bottomAnchor, constant: 40),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func durationSliderChanged(_ sender: UISlider) {
        let duration = Int(sender.value)
        durationValueLabel.text = "\(duration)"
        videoSettings.clipDuration = duration
    }
    
    @objc private func saveButtonTapped() {
        delegate?.didUpdateSettings(videoSettings)
        navigationController?.popViewController(animated: true)
    }
}
