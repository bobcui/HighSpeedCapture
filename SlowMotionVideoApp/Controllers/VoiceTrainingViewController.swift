import UIKit
import Speech

protocol VoiceTrainingViewControllerDelegate: AnyObject {
    func voiceTrainingDidComplete(with confidence: Float)
}

class VoiceTrainingViewController: UIViewController {
    
    // MARK: - Properties
    private let speechRecognitionService = SpeechRecognitionService()
    private var confidenceScore: Float = 0.0
    private var successCount = 0
    private var attemptCount = 0
    private let requiredSuccesses = 3
    private let maxAttempts = 10
    
    weak var delegate: VoiceTrainingViewControllerDelegate?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Voice Command Trainer"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's practice saying the 'ready' command.\nThis will help improve recognition accuracy."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "• Speak clearly at a moderate pace\n• Keep consistent volume and tone\n• Practice in the environment you'll use the app"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to begin training"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Success: 0/3"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Training", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Say 'Ready'", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        
        // Set up speech recognition
        speechRecognitionService.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestSpeechRecognitionPermission()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(tipsLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(startButton)
        view.addSubview(recordButton)
        view.addSubview(nextButton)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Instruction Label
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Tips Label
            tipsLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30),
            tipsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tipsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: 40),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Progress Label
            progressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 10),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Feedback Label
            feedbackLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            // Record Button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 30),
            recordButton.widthAnchor.constraint(equalToConstant: 200),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Start Button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 30),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Next Button
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 20),
            nextButton.widthAnchor.constraint(equalToConstant: 200),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Close Button
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActions() {
        startButton.addTarget(self, action: #selector(startTrainingTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func startTrainingTapped() {
        // Start training
        startButton.isHidden = true
        recordButton.isHidden = false
        
        statusLabel.text = "Attempt 1: Say 'ready'"
        attemptCount = 0
        successCount = 0
        updateProgressLabel()
    }
    
    @objc private func recordTapped() {
        // Toggle recording state
        if speechRecognitionService.isListening {
            stopListening()
            recordButton.setTitle("Say 'Ready'", for: .normal)
            recordButton.backgroundColor = .systemRed
        } else {
            startListening()
            recordButton.setTitle("Listening...", for: .normal)
            recordButton.backgroundColor = .systemGreen
            nextButton.isHidden = true
            
            // Update attempt count
            attemptCount += 1
            statusLabel.text = "Attempt \(attemptCount): Say 'ready'"
        }
    }
    
    @objc private func nextTapped() {
        // Move to next attempt if not done
        if successCount < requiredSuccesses && attemptCount < maxAttempts {
            recordButton.isHidden = false
            nextButton.isHidden = true
            feedbackLabel.text = ""
        } else {
            // Complete the training
            completeTraining()
        }
    }
    
    @objc private func closeTapped() {
        // Stop listening and dismiss
        if speechRecognitionService.isListening {
            stopListening()
        }
        
        // Notify delegate with final confidence score
        let finalConfidence = Float(successCount) / Float(max(1, attemptCount))
        delegate?.voiceTrainingDidComplete(with: finalConfidence)
        
        dismiss(animated: true)
    }
    
    // MARK: - Speech Recognition Methods
    private func requestSpeechRecognitionPermission() {
        speechRecognitionService.requestAuthorization { [weak self] isAuthorized in
            guard let self = self else { return }
            
            if !isAuthorized {
                self.showPermissionAlert()
            }
        }
    }
    
    private func startListening() {
        do {
            try speechRecognitionService.startListening()
        } catch {
            showAlert(title: "Error", message: "Could not start speech recognition: \(error.localizedDescription)")
        }
    }
    
    private func stopListening() {
        speechRecognitionService.stopListening()
    }
    
    // MARK: - Training Logic
    private func processRecognizedCommand(_ command: String, confidence: Float) {
        // Stop listening after processing
        stopListening()
        
        // Check if the command is "ready"
        if command.lowercased() == "ready" {
            successCount += 1
            confidenceScore += confidence
            
            feedbackLabel.text = "✓ Success! Good pronunciation. Confidence: \(Int(confidence * 100))%"
            feedbackLabel.textColor = .systemGreen
            
            // Check if training is complete
            if successCount >= requiredSuccesses {
                completeTraining()
            } else {
                // Show next button
                recordButton.isHidden = true
                nextButton.isHidden = false
                updateProgressLabel()
            }
        } else {
            // Provide feedback for incorrect command
            feedbackLabel.text = "✗ Not recognized as 'ready'. Try again focusing on clear pronunciation."
            feedbackLabel.textColor = .systemRed
            
            // Check if max attempts reached
            if attemptCount >= maxAttempts {
                completeTraining()
            } else {
                // Allow another attempt
                recordButton.setTitle("Try Again", for: .normal)
                nextButton.isHidden = false
                updateProgressLabel()
            }
        }
    }
    
    private func updateProgressLabel() {
        progressLabel.text = "Success: \(successCount)/\(requiredSuccesses) (Attempts: \(attemptCount)/\(maxAttempts))"
    }
    
    private func completeTraining() {
        // Calculate final confidence
        let averageConfidence = successCount > 0 ? confidenceScore / Float(successCount) : 0
        
        // Update UI
        recordButton.isHidden = true
        nextButton.isHidden = true
        
        if successCount >= requiredSuccesses {
            statusLabel.text = "Training Complete!"
            feedbackLabel.text = "Your voice pattern for 'ready' has been recorded with \(Int(averageConfidence * 100))% confidence"
            feedbackLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Training Incomplete"
            feedbackLabel.text = "Additional practice is recommended to improve recognition accuracy"
            feedbackLabel.textColor = .systemOrange
        }
        
        // Update progress
        progressLabel.text = "Success rate: \(successCount)/\(attemptCount) attempts"
    }
    
    // MARK: - Helper Methods
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access Required",
            message: "Please enable microphone access in Settings to use the voice training feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SpeechRecognitionDelegate
extension VoiceTrainingViewController: SpeechRecognitionDelegate {
    func speechRecognitionDidDetectCommand(_ command: String) {
        // When a command is detected, process it with an assumed confidence level
        // In a real app, we would get the actual confidence from the speech recognition result
        let assumedConfidence: Float = 0.8
        processRecognizedCommand(command, confidence: assumedConfidence)
    }
}