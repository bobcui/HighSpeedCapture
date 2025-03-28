import UIKit

protocol CameraControlsViewDelegate: AnyObject {
    func didTapRecordButton()
    func didTapSettingsButton()
}

class CameraControlsView: UIView {
    
    // MARK: - Properties
    weak var delegate: CameraControlsViewDelegate?
    
    // MARK: - UI Elements
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
        
        addSubview(recordButton)
        addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            recordButton.widthAnchor.constraint(equalToConstant: 60),
            recordButton.heightAnchor.constraint(equalToConstant: 60),
            
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 80),
            settingsButton.heightAnchor.constraint(equalToConstant: 40)
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
    func updateRecordButtonState(isRecording: Bool) {
        recordButton.setTitle(isRecording ? "Recording..." : "Ready", for: .normal)
        recordButton.backgroundColor = isRecording ? .systemRed.withAlphaComponent(0.7) : .systemRed
    }
}
