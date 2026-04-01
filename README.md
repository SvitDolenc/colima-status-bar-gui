# Colima GUI

A simple macOS menu bar application to monitor and control Colima.

## Features
- Shows current Colima status in the menu bar.
- One-click **Start** and **Stop** buttons.
- Automatic polling every 5 seconds.
- Lightweight and native (SwiftUI).

## Requirements
- macOS 13.0 or later.
- [Colima](https://github.com/abiosoft/colima) installed (e.g., via Homebrew).

## How to Run
To start the app, run:
```bash
make run
```

To build a release binary:
```bash
make build
```
The binary will be located at `.build/release/ColimaGUI`.

## Usage
Click the Colima icon (a circle) in your menu bar to see the status and control buttons.
- 🟢 Green: Running
- ⚪️ Gray: Stopped
- 🟡 Yellow: Starting/Stopping
