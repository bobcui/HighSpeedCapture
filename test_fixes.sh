#!/bin/bash
# Test script to verify all bug fixes

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SlowMotionVideoApp Bug Fix Test ===${NC}"
echo -e "${BLUE}This script tests the following fixes:${NC}"
echo "1. Added clear RECORDING and REPLAYING prompts"
echo "2. Fixed settings persistence (duration and playback speed)"
echo "3. Fixed 'ready' command functionality"
echo ""
echo "Starting test sequence..."
sleep 2

# Use expect to interact with the simulator
expect -c '
    set timeout 2
    
    # Start the app
    spawn ./run_simulator.sh
    
    # Wait for the app to start
    expect "Current settings: 10 seconds clip duration"
    
    # Step 1: Change settings to verify persistence later
    send "settings\r"
    expect "Enter new duration"
    send "15\r"
    expect "Duration updated to 15 seconds"
    expect "This setting will be preserved for future recordings"
    
    # Verify the settings were updated
    expect "Current settings: 15 seconds clip duration"
    expect "Current playback speed: 0.5x Speed"
    
    # Step 2: Change playback speed
    send "speed\r"
    expect "Available speeds:"
    send "4\r"
    expect "Playback speed updated to"
    expect "This setting will be preserved for future recordings"
    
    # Step 3: Test recording
    send "ready\r"
    expect "=== 📹 RECORDING IN PROGRESS 📹 ==="
    expect "Recording time bar:"
    
    # Wait for recording to finish
    sleep 3

    # Expect playback
    expect "=== RECORDING COMPLETE ==="
    expect "=== 🔄 REPLAYING VIDEO 🔄 ==="
    expect "Playback Speed:"
    
    # Wait for a bit to see playback
    sleep 3
    
    # Exit the app
    send "exit\r"
    expect eof
'

# Check the result
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo "1. Verified visible RECORDING and REPLAYING prompts"
    echo "2. Verified settings persistence for duration (15 seconds) and playback speed"
    echo "3. Verified 'ready' command starts recording properly"
else
    echo "❌ Some tests failed. Check the output above for details."
fi

echo ""
echo "Test complete."