#!/bin/bash
# Simple demonstration script for SlowMotionVideoApp

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SlowMotionVideoApp Demo ===${NC}"
echo -e "${BLUE}This script demonstrates the main features of the app:${NC}"
echo "1. UI improvements with clear RECORDING and REPLAYING prompts"
echo "2. Recording time indicator with progress bar"
echo "3. Playback visualization with frame information"
echo "4. Settings persistence and camera switching"
echo ""
echo -e "${YELLOW}Starting app in 3 seconds...${NC}"
sleep 3

# Run the simulator with customized interaction
./run_simulator.sh << EOF
settings
12
speed
7
ready
switch
EOF

echo -e "\n${GREEN}Demo complete!${NC}"
echo "The demo showcased:"
echo "1. ✅ Setting clip duration to 12 seconds"
echo "2. ✅ Setting playback speed to 1.75x"
echo "3. ✅ Starting recording with 'ready' command"
echo "4. ✅ Visual RECORDING and REPLAYING prompts with progress indicators"
echo "5. ✅ Switching camera (front/back) with status indicators"
exit 0