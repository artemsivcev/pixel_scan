#!/bin/bash

codeAnalyze() {
    cd "../lib" || exit 1

    EXIT_STATUS=0

    echo "⏳ Analyzing code..."
    flutter analyze || EXIT_STATUS=$?
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "⛔️ Analyzing error: Please correct the issues found."
        exit $EXIT_STATUS
    fi
    echo "✅ Code analyzed"
}

codeFormat() {
    cd "../lib" || exit 1

    EXIT_STATUS=0

    echo "⏳ Formatting code ..."
    dart format . || EXIT_STATUS=$?
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "⛔️ Formatting error: Please format the code"
        exit $EXIT_STATUS
    fi
    echo "✅ Code formatted"

    echo Exit status: $EXIT_STATUS
    exit $EXIT_STATUS
}

case $1 in
    *)
        codeAnalyze
        codeFormat
        ;;
esac