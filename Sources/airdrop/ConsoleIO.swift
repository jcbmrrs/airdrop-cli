//
//  ConsoleIO.swift
//  airdrop
//
//  Created by Volodymyr Klymenko on 2020-12-30.
//

import Foundation

enum OutputType {
    case error
    case standard
}

class ConsoleIO {
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print("\(message)")
        case .error:
            fputs("\n❌ Error: \(message)\n", stderr)
        }
    }

    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

        writeMessage("USAGE: \(executableName) <file1> [file2] [file3] ...")
        writeMessage("    file1, file2, file3, ... – URLs or paths to files to AirDrop")
        writeMessage("    You can specify multiple items - both local files and web URLs, and you can mix them too.")
        writeMessage("    You can also pipe input from other commands: command | \(executableName)")
        writeMessage("\nEXAMPLES:")
        writeMessage("    \(executableName) document.pdf")
        writeMessage("    \(executableName) image1.jpg image2.png")
        writeMessage("    \(executableName) file.txt https://apple.com/")
        writeMessage("    find . -name '*.pdf' | \(executableName) -")
        writeMessage("    \(executableName) --device \"iPhone\" document.pdf")
        writeMessage("\nOPTIONS:")
        writeMessage("    -h, --help – print help info")
        writeMessage("    -l, --list-devices – show available AirDrop devices (API limited)")
        writeMessage("    -d, --device <name> – specify target device (not fully supported)")
        writeMessage("    - – read file paths from stdin")
        writeMessage("\nNOTE:")
        writeMessage("    Device discovery and selection are limited by Apple's NSSharingService API.")
        writeMessage("    The system picker UI will always appear for final device selection.")
    }

    func printAPILimitation() {
        writeMessage("⚠️  This feature is limited by Apple's APIs", to: .error)
        writeMessage("NSSharingService does not expose device discovery or selection.", to: .error)
    }

    func printDeviceList(_ devices: [String]) {
        writeMessage("\nAvailable AirDrop Devices:")
        if devices.isEmpty {
            writeMessage("  (API cannot discover devices)")
        } else {
            for (index, device) in devices.enumerated() {
                writeMessage("  \(index + 1). \(device)")
            }
        }
    }
}
