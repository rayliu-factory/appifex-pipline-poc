#!/bin/bash
set -e

echo "🚀 Setting up TodoApp Xcode Project..."

# Check if xcodegen is available
if command -v xcodegen &> /dev/null; then
    echo "✅ Using XcodeGen to generate project..."
    xcodegen generate
    echo "✅ Project generated: TodoApp.xcodeproj"
    echo ""
    echo "📱 To open the project:"
    echo "   open TodoApp.xcodeproj"
else
    echo "⚠️  XcodeGen not found. Using Swift Package Manager integration instead."
    echo ""
    echo "📱 To work with this project in Xcode:"
    echo "   1. Open Package.swift in Xcode:"
    echo "      open Package.swift"
    echo ""
    echo "   2. Xcode will automatically:"
    echo "      - Resolve dependencies"
    echo "      - Create schemes for building"
    echo "      - Enable running in the simulator"
    echo ""
    echo "💡 To install XcodeGen for native project support:"
    echo "   brew install xcodegen"
    echo "   Then run this script again."
fi

echo ""
echo "✅ Setup complete!"
