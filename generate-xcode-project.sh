#!/bin/bash
# Script to generate Xcode project from Swift Package
# Usage: ./generate-xcode-project.sh

echo "Generating Xcode project..."
swift package generate-xcodeproj

if [ $? -eq 0 ]; then
    echo "✅ Xcode project generated successfully!"
    echo "Open TodoApp.xcodeproj to build and run the app"
else
    echo "❌ Failed to generate Xcode project"
    echo "Note: This command may be deprecated. Use 'open Package.swift' in Xcode instead."
fi
