# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`airdrop-cli` is a command-line tool for sharing files and URLs to Apple devices via AirDrop from the terminal. It's a Swift package that uses macOS Cocoa frameworks, specifically `NSSharingService` for AirDrop functionality.

## Development Commands

### Building
```bash
# Build release version
swift build -c release --disable-sandbox

# Or use make
make
```

### Testing
```bash
# Run all tests
swift test

# Run specific test
swift test --filter AirdropCLITests.testExample
```

### Installation
```bash
# Install to /usr/local/bin (requires sudo)
sudo make install

# Install to custom location
make PREFIX="/custom/path"

# Uninstall
sudo make uninstall
```

### Clean build artifacts
```bash
make clean
# or
rm -rf .build
```

## Architecture

### Application Flow

1. **Entry Point** (`main.swift`): Initializes `AirDropCLI` as NSApplication delegate and starts the app run loop
2. **Core Logic** (`AirDropCLI.swift`): NSApplicationDelegate that handles:
   - Command-line argument parsing (files, URLs, stdin via `-`, or flags)
   - File validation and URL detection (supports http/https URLs)
   - AirDrop sharing via `NSSharingService`
   - Individual vs batch sharing logic
   - Device discovery and selection flags (with API limitation handling)
3. **Console I/O** (`ConsoleIO.swift`): Handles all terminal output (stdout/stderr)

### Key Technical Details

**Sharing Modes:**
- **Batch mode**: Shares all items at once when possible (default for files-only or single URL)
- **Individual mode**: Shares items one-by-one when:
  - Mixed content (URLs + files together)
  - Multiple URLs (AirDrop limitation: can't share multiple URLs at once)

**Stdin Support:**
- Pass `-` as argument to read file paths from stdin
- Allows piping from other commands (e.g., `find . -name '*.pdf' | airdrop -`)

**URL vs File Detection:**
- URLs are detected by checking for `http://` or `https://` scheme
- Everything else is treated as a file path and validated with FileManager

**Delegate Pattern:**
- `AirDropCLI` implements `NSSharingServiceDelegate` to handle:
  - Success/failure callbacks for each share operation
  - Window positioning for AirDrop UI
  - Sequential sharing in individual mode

### Important State Management

The individual sharing mode uses instance variables to track progress:
- `isIndividualSharing`: Flag to enable sequential sharing
- `individualSharingItems`: Queue of remaining items to share
- `individualSharingSuccessful/Failed`: Counters for final summary

When an item is shared successfully or fails, the delegate callbacks trigger `shareNextItem()` with the remaining queue, implementing a recursive-style sequential share.

## CLI Flags

**Available flags:**
- `-h, --help`: Print usage information
- `-l, --list-devices`: Show available AirDrop devices (documents API limitation)
- `-d, --device <name>`: Specify target device name (shows warning about manual selection)
- `-`: Read file paths from stdin

**Important API Limitation:**
NSSharingService does NOT provide public APIs for device discovery or programmatic recipient selection. The `--list-devices` and `--device` flags transparently communicate this limitation to users rather than silently failing. Research was conducted into alternative approaches (NetServiceBrowser, Network.framework, MultipeerConnectivity) but no viable public API solution exists. See AirDropCLI.swift:263-278 for detailed documentation.

## Platform Requirements

- macOS only (uses Cocoa frameworks)
- Xcode 11.4+ required for building
- Swift 5.3+ (specified in Package.swift)
- macOS 13.0+ features used (activation policy)
