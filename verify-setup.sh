#!/bin/bash

echo "🔍 Verifying TodoApp Xcode Project Setup..."
echo ""

# Check for required files
echo "📁 Checking project files..."

if [ -f "project.yml" ]; then
    echo "✅ project.yml found"
else
    echo "❌ project.yml missing"
fi

if [ -d "TodoApp.xcodeproj" ]; then
    echo "✅ TodoApp.xcodeproj found"
else
    echo "❌ TodoApp.xcodeproj missing"
fi

if [ -f "Package.swift" ]; then
    echo "✅ Package.swift found"
else
    echo "❌ Package.swift missing"
fi

echo ""
echo "📱 Checking source files..."

SOURCE_FILES=(
    "Sources/TodoApp/Models/Todo.swift"
    "Sources/TodoApp/Services/TodoRepository.swift"
    "Sources/TodoApp/DependencyInjection/AppContainer.swift"
    "Sources/TodoApp/Features/TodoList/TodoListFeature.swift"
    "Sources/TodoApp/Features/TodoList/TodoListView.swift"
    "Sources/TodoApp/Features/TodoDetail/TodoDetailFeature.swift"
    "Sources/TodoApp/Features/TodoDetail/TodoDetailView.swift"
    "Sources/TodoApp/Features/TodoDetail/TodoFormFeature.swift"
    "Sources/TodoApp/Features/TodoDetail/TodoFormView.swift"
    "Sources/TodoApp/App/AppFeature.swift"
    "Sources/TodoApp/App/AppView.swift"
    "Sources/TodoApp/App/TodoApp.swift"
)

MISSING=0
for file in "${SOURCE_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file missing"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
echo "🧪 Checking test files..."

if [ -f "Tests/TodoAppTests/TodoListFeatureTests.swift" ]; then
    echo "✅ TodoListFeatureTests.swift found"
else
    echo "❌ TodoListFeatureTests.swift missing"
fi

echo ""
echo "📚 Checking documentation..."

DOCS=(
    "README.md"
    "QUICKSTART.md"
    "ARCHITECTURE.md"
    "APP_FLOW.md"
    "PROJECT_SUMMARY.md"
    "XCODE_PROJECT_GUIDE.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo "✅ $doc"
    else
        echo "❌ $doc missing"
    fi
done

echo ""
echo "🔧 Checking tools..."

if command -v xcodegen &> /dev/null; then
    XCODEGEN_VERSION=$(xcodegen --version)
    echo "✅ XcodeGen installed ($XCODEGEN_VERSION)"
else
    echo "⚠️  XcodeGen not found (optional, but recommended)"
fi

if command -v swift &> /dev/null; then
    SWIFT_VERSION=$(swift --version | head -1)
    echo "✅ Swift installed ($SWIFT_VERSION)"
else
    echo "❌ Swift not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $MISSING -eq 0 ]; then
    echo "✅ All checks passed! Your project is ready."
    echo ""
    echo "🚀 To get started:"
    echo "   open TodoApp.xcodeproj"
else
    echo "⚠️  Some files are missing. Please check the output above."
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
