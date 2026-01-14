<<<<<<< HEAD
# Latex Scan
=======
# LaTeX Scan
>>>>>>> acfa1e14c22ae334984f77d3012e0e2581e57016

A macOS menu bar app that captures any math equation on screen and instantly converts it to LaTeX using Google's Gemini AI.

## Features

- **Global Hotkey**: Press `Cmd+Shift+L` anywhere to start capturing
- **Screen Selection**: Draw a rectangle around any math equation
- **AI-Powered Conversion**: Uses Gemini AI to accurately convert images to LaTeX
- **Auto-Copy**: LaTeX is automatically copied to your clipboard
- **Notifications**: Get notified when conversion is complete

## Requirements

- macOS 13.0+
- Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Setup

1. Open the app - it will appear in your menu bar as a function (ƒ) icon
2. Click the icon and go to **Settings > API**
3. Enter your Gemini API key
4. Grant screen recording permission when prompted

## Usage

1. Press `Cmd+Shift+L` (or click "Scan Now" in the popover)
2. Select the area containing the math equation
3. Wait for the AI to process the image
4. The LaTeX is automatically copied to your clipboard

## Permissions

The app requires:
- **Screen Recording**: To capture the selected screen region
- **Accessibility**: For global hotkey support

## Building

Open `latexscan.xcodeproj` in Xcode and build for your Mac.

## License

MIT
