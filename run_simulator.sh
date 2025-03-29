#!/bin/bash
# Direct run script for SlowMotionSimulator
# This bypasses Swift Package Manager build issues

# Make sure the script is executable
chmod +x run_simulator.sh

# Clear the screen for better visibility
clear

# Print a header
echo "==================================================="
echo "  SlowMotionVideoApp CLI Simulator"
echo "  Starting up the simulator environment..."
echo "==================================================="
echo ""

# Compile and run directly with simulator.swift included first
# This ensures all the necessary classes from simulator.swift are available
swift simulator.swift SlowMotionSimulator/main.swift