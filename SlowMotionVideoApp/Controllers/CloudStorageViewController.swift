import UIKit

/**
 * CloudStorageViewController is responsible for the cloud storage UI
 *
 * This view controller provides the user interface for:
 * - Selecting a cloud provider (iCloud, Dropbox, Google Drive)
 * - Authenticating with the selected provider
 * - Uploading videos to the cloud
 * - Configuring sharing options (public/private, comments, downloads)
 * - Sharing videos via generated links
 *
 * The controller works with CloudStorageService to handle the actual cloud operations
 * and communicates back to the CameraViewController through its delegate.
 */

/// Protocol for communicating from CloudStorageViewController back to its presenting controller
protocol CloudStorageViewControllerDelegate: AnyObject {
    func cloudStorageViewController(_ controller: CloudStorageViewController, didShareVideo url: URL)
    func cloudStorageViewControllerDidCancel(_ controller: CloudStorageViewController)
}

class CloudStorageViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CloudStorageViewControllerDelegate?
    private let cloudStorageService = CloudStorageService()
    private var videoURL: URL?
    private var cloudURL: URL?
    private var sharingOptions = VideoSharingOptions.defaultOptions
    
    // MARK: - UI Elements
    
    private lazy var providerSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [
            CloudStorageProvider.iCloud.displayName,
            CloudStorageProvider.dropbox.displayName,
            CloudStorageProvider.googleDrive.displayName
        ])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(providerChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload Video", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Video", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        progressView.isHidden = true
        return progressView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select a cloud provider and upload your video"
        return label
    }()
    
    private lazy var publicSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(publicSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var publicLabel: UILabel = {
        let label = UILabel()
        label.text = "Public Video"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var allowCommentsSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = true
        switchControl.addTarget(self, action: #selector(commentsSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.text = "Allow Comments"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var allowDownloadsSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(downloadsSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var downloadsLabel: UILabel = {
        let label = UILabel()
        label.text = "Allow Downloads"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var sharingOptionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set delegate for cloud storage service
        cloudStorageService.delegate = self
        
        // Set initial provider
        providerChanged()
    }
    
    // MARK: - Initialization
    
    init(videoURL: URL?) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add UI elements to view
        view.addSubview(providerSegmentedControl)
        view.addSubview(uploadButton)
        view.addSubview(shareButton)
        view.addSubview(cancelButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        
        // Setup sharing options stack view
        setupSharingOptionsStackView()
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Provider selector
            providerSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            providerSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            providerSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: providerSegmentedControl.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Progress view
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 15),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Sharing options
            sharingOptionsStackView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 25),
            sharingOptionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sharingOptionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Upload button
            uploadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            uploadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            uploadButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -15),
            uploadButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Share button
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -15),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupSharingOptionsStackView() {
        view.addSubview(sharingOptionsStackView)
        
        // Create horizontal stack views for each option
        let publicOptionView = createOptionRow(label: publicLabel, control: publicSwitch)
        let commentsOptionView = createOptionRow(label: commentsLabel, control: allowCommentsSwitch)
        let downloadsOptionView = createOptionRow(label: downloadsLabel, control: allowDownloadsSwitch)
        
        // Add rows to main stack view
        sharingOptionsStackView.addArrangedSubview(publicOptionView)
        sharingOptionsStackView.addArrangedSubview(commentsOptionView)
        sharingOptionsStackView.addArrangedSubview(downloadsOptionView)
    }
    
    private func createOptionRow(label: UILabel, control: UIView) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(label)
        containerView.addSubview(control)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            control.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            control.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: sharingOptionsStackView.widthAnchor)
        ])
        
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func providerChanged() {
        let selectedIndex = providerSegmentedControl.selectedSegmentIndex
        let provider: CloudStorageProvider
        
        switch selectedIndex {
        case 0:
            provider = .iCloud
        case 1:
            provider = .dropbox
        case 2:
            provider = .googleDrive
        default:
            provider = .iCloud
        }
        
        // Update service with the new provider
        cloudStorageService.setProvider(provider)
        
        // Update UI based on authentication status
        updateAuthenticationStatus()
    }
    
    @objc private func uploadButtonTapped() {
        guard let videoURL = videoURL else {
            statusLabel.text = "No video selected for upload"
            return
        }
        
        if cloudStorageService.isAuthenticated() {
            // Start upload process
            startUpload(videoURL: videoURL)
        } else {
            // Authenticate first
            authenticate()
        }
    }
    
    @objc private func shareButtonTapped() {
        guard let cloudURL = cloudURL else {
            statusLabel.text = "No video available to share"
            return
        }
        
        // Generate sharing link with current options
        let sharingURL = cloudStorageService.shareVideo(at: cloudURL, options: sharingOptions)
        
        // Notify delegate
        delegate?.cloudStorageViewController(self, didShareVideo: sharingURL)
        
        // Display success
        statusLabel.text = "Video shared successfully!"
        
        // Simulate presenting activity view controller (would happen in real app)
        UIView.animate(withDuration: 0.3) {
            self.statusLabel.alpha = 0
        } completion: { _ in
            self.statusLabel.text = "Video shared successfully!"
            UIView.animate(withDuration: 0.3) {
                self.statusLabel.alpha = 1
            }
        }
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cloudStorageViewControllerDidCancel(self)
    }
    
    @objc private func publicSwitchChanged() {
        sharingOptions.isPublic = publicSwitch.isOn
    }
    
    @objc private func commentsSwitchChanged() {
        sharingOptions.allowComments = allowCommentsSwitch.isOn
    }
    
    @objc private func downloadsSwitchChanged() {
        sharingOptions.allowDownloads = allowDownloadsSwitch.isOn
    }
    
    // MARK: - Helper Methods
    
    private func updateAuthenticationStatus() {
        let isAuthenticated = cloudStorageService.isAuthenticated()
        let providerName = cloudStorageService.currentProviderName()
        
        if isAuthenticated {
            statusLabel.text = "Authenticated with \(providerName)"
            uploadButton.setTitle("Upload to \(providerName)", for: .normal)
        } else {
            statusLabel.text = "Not authenticated with \(providerName)"
            uploadButton.setTitle("Sign in to \(providerName)", for: .normal)
        }
    }
    
    private func authenticate() {
        statusLabel.text = "Authenticating..."
        
        cloudStorageService.authenticate { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.updateAuthenticationStatus()
                    
                    // If we have a video URL, start upload automatically
                    if let videoURL = self.videoURL {
                        self.startUpload(videoURL: videoURL)
                    }
                } else if let error = error {
                    self.statusLabel.text = "Authentication failed: \(error.localizedDescription)"
                } else {
                    self.statusLabel.text = "Authentication failed. Please try again."
                }
            }
        }
    }
    
    private func startUpload(videoURL: URL) {
        // Update UI
        statusLabel.text = "Uploading video..."
        progressView.progress = 0.0
        progressView.isHidden = false
        
        // Disable upload button during upload
        uploadButton.isEnabled = false
        
        // Start upload
        cloudStorageService.uploadVideo(at: videoURL)
    }
}

// MARK: - CloudStorageServiceDelegate

extension CloudStorageViewController: CloudStorageServiceDelegate {
    func cloudStorageService(_ service: CloudStorageService, didUploadVideo url: URL, to provider: CloudStorageProvider) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Store the cloud URL
            self.cloudURL = url
            
            // Update UI
            self.statusLabel.text = "Video uploaded successfully to \(provider.displayName)!"
            self.uploadButton.isEnabled = true
            self.shareButton.isEnabled = true
            
            // Show sharing options
            self.sharingOptionsStackView.isHidden = false
        }
    }
    
    func cloudStorageService(_ service: CloudStorageService, didFailWithError error: CloudStorageError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update UI
            self.statusLabel.text = "Error: \(error.localizedDescription)"
            self.uploadButton.isEnabled = true
            self.progressView.isHidden = true
        }
    }
    
    func cloudStorageService(_ service: CloudStorageService, didUpdateProgress progress: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update progress bar
            self.progressView.progress = progress
            
            // If we're done, hide the progress bar after a short delay
            if progress >= 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.progressView.isHidden = true
                }
            }
        }
    }
}