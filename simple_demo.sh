#!/bin/bash

# Simple demo script for SlowMotionVideoApp simulator
echo -e "\033[1;36m===================================\033[0m"
echo -e "\033[1;36m SlowMotionVideoApp Demo\033[0m"
echo -e "\033[1;36m===================================\033[0m\n"

echo -e "\033[1;34m==== Showing app information ====\033[0m"
swift SlowMotionSimulator/main.swift <<< "exit" | head -n 25

echo -e "\n\033[1;32mDemo completed.\033[0m"
echo -e "\033[1;32m--------------------------------\033[0m\n"

echo -e "\033[1;36m===================================\033[0m"
echo -e "\033[1;36m Features demonstrated:\033[0m"
echo -e "\033[1;36m - 120FPS video recording\033[0m"
echo -e "\033[1;36m - Configurable recording duration\033[0m"
echo -e "\033[1;36m - Multiple playback speeds\033[0m"
echo -e "\033[1;36m - Voice command recognition\033[0m"
echo -e "\033[1;36m - Front/back camera switching\033[0m"
echo -e "\033[1;36m - Cloud storage integration\033[0m"
echo -e "\033[1;36m===================================\033[0m"