#!/bin/bash

# Demo script for SlowMotionVideoApp simulator

# Function to send commands to the simulator and wait for response
function run_simulator_command() {
    local command="$1"
    local description="$2"
    
    echo -e "\n\033[1;34m==== $description ====\033[0m"
    echo -e "\033[0;33mSending command: $command\033[0m\n"
    
    # Run the simulator with the command
    echo "$command" | swift SlowMotionSimulator/main.swift | head -n 50
    
    echo -e "\n\033[1;32mCommand completed.\033[0m"
    echo -e "\033[1;32m--------------------------------\033[0m\n"
    sleep 1
}

echo -e "\033[1;36m===================================\033[0m"
echo -e "\033[1;36m SlowMotionVideoApp Demo\033[0m"
echo -e "\033[1;36m===================================\033[0m\n"

# Run the basic commands to demonstrate functionality
run_simulator_command "ready" "Recording a 10-second video at 120FPS"
run_simulator_command "speed" "Changing playback speed"
run_simulator_command "3" "Selecting half-speed playback"
run_simulator_command "settings" "Changing clip duration"
run_simulator_command "15" "Setting clip duration to 15 seconds"
run_simulator_command "voice" "Enabling voice commands"
run_simulator_command "train" "Training voice recognition"
run_simulator_command "ready" "Simulating voice command recognition"
run_simulator_command "faster" "Increasing playback speed during playback"
run_simulator_command "cloud" "Accessing cloud storage options"
run_simulator_command "1" "Selecting iCloud as provider"
run_simulator_command "yes" "Authenticating with iCloud"
run_simulator_command "1" "Uploading video to iCloud"
run_simulator_command "yes" "Making video public"
run_simulator_command "yes" "Allowing comments"
run_simulator_command "yes" "Allowing downloads"
run_simulator_command "switch" "Switching to front camera"
run_simulator_command "ready" "Recording from front camera"
run_simulator_command "switch" "Switching back to rear camera"

echo -e "\033[1;36m===================================\033[0m"
echo -e "\033[1;36m Demo Complete!\033[0m"
echo -e "\033[1;36m===================================\033[0m\n"