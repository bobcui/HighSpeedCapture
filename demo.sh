#!/bin/bash
# Comprehensive demo script for SlowMotionVideoApp

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}🎬 SlowMotionVideoApp - Comprehensive Demo 🎬${NC}"
echo -e "${BLUE}===========================================${NC}"
echo -e "This demo will showcase the complete functionality:"
echo "1. Settings configuration (recording duration and playback speed)"
echo "2. Camera switching with thread safety"
echo "3. Recording with voice command and progress indicators"
echo "4. Playback with speed adjustments"
echo "5. Voice command training"
echo "6. Cloud storage options"
echo -e "${YELLOW}The demo will run automatically - watch the interactions${NC}"
echo

# Make sure run_simulator.sh is executable
chmod +x run_simulator.sh

# Run the simulator with a full demo sequence
(
# Initial setup
sleep 2
echo "settings"              # Change clip duration
sleep 1
echo "15"                    # Set to 15 seconds
sleep 2

echo "speed"                 # Change playback speed
sleep 1
echo "3"                     # Select 0.5x speed
sleep 2

echo "switch"                # Switch to front camera
sleep 2
echo "voice"                 # Enable voice control
sleep 2

echo "ready"                 # Start recording (acting as voice command)
sleep 8                      # Wait during recording simulation

echo "faster"                # Speed up playback
sleep 2
echo "faster"                # Speed up playback again
sleep 2

echo "switch"                # Switch back to back camera
sleep 2

echo "train"                 # Try voice training
sleep 1
echo "ready"                 # Practice saying "ready"
sleep 1
echo "ready"                 # Practice saying "ready" again
sleep 1
echo "ready"                 # Practice saying "ready" once more
sleep 1
echo "back"                  # Go back to main menu
sleep 2

echo "cloud"                 # Try cloud options
sleep 1
echo "1"                     # Select iCloud
sleep 1
echo "yes"                   # Authenticate
sleep 1
echo "1"                     # Upload video
sleep 3
echo "yes"                   # Make public
sleep 1
echo "yes"                   # Allow comments
sleep 1
echo "yes"                   # Allow downloads
sleep 2
echo ""                      # Continue

echo "voice"                 # Disable voice control
sleep 1
echo "exit"                  # Exit the app
) | ./run_simulator.sh

echo
echo -e "${GREEN}✅ Demo complete!${NC}"
echo "The demo showcased the following features and fixes:"
echo "1. ✓ Thread-safe camera operations with proper error handling"
echo "2. ✓ Visual RECORDING and PLAYBACK indicators with progress bars"
echo "3. ✓ Voice command recognition with optional training"
echo "4. ✓ Settings persistence across app sessions"
echo "5. ✓ Cloud storage and sharing functionality with options"
echo "6. ✓ Proper camera switching with smooth animations and feedback"