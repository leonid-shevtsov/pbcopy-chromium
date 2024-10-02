import AppKit
import ArgumentParser
import Foundation
import NIO
import NIOFoundationCompat

@main
struct PbcopyChromium: ParsableCommand {
    static let pasteboardType = NSPasteboard.PasteboardType("org.chromium.web-custom-data")

    @Option(help: "MIME type of the contents to copy")
    var type: String

    @Argument(help: "Filename to read (or standard input)")
    var inputFile: String?

    @Flag(help: "Instead of copying, paste the clipboard to standard output")
    var paste = false

    mutating func run() throws {
        if paste {
            try runPaste()
        } else {
            try runCopy()
        }
    }

    func runCopy() throws {
        guard let contents = getContents() else {
            return
        }

        var buffer = ByteBuffer()

        // Entry count
        writeInt32(&buffer, 1)
        // The only entry
        writeString(&buffer, type)
        writeString(&buffer, contents)

        var bufferWithLength = ByteBuffer()

        // Payload size before payload
        writeInt32(&bufferWithLength, UInt32(buffer.readableBytes))
        bufferWithLength.writeBuffer(&buffer)

        let data = bufferWithLength.readData(length: bufferWithLength.readableBytes)!

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: Self.pasteboardType)
    }

    func getContents() -> String? {
        var input: FileHandle

        if let inputFile {
            guard let fileInput = FileHandle(forReadingAtPath: inputFile) else {
                fputs("No such file\n", stderr)
                return nil
            }
            input = fileInput
        } else {
            input = FileHandle.standardInput
        }

        do {
            guard let contentsData = try input.readToEnd() else {
                fputs("No input\n", stderr)
                return nil
            }
            return String(decoding: contentsData, as: UTF8.self)
        } catch {
            fputs("failed to read input: \(error)\n", stderr)
            return nil
        }
    }

    func runPaste() throws {
        let pasteboard = NSPasteboard.general
        guard let data = pasteboard.data(forType: Self.pasteboardType) else {
            fputs("no data in clipboard, copy something from Chromium first\n", stderr)
            return
        }

        var buffer = ByteBuffer(data: data)

        guard readInt32(&buffer) != nil else {
            fputs("could not decode buffer contents\n", stderr)
            return
        }

        guard let entryCount = readInt32(&buffer) else {
            fputs("could not decode buffer contents\n", stderr)
            return
        }

        if entryCount < 1 {
            fputs("expected at least 1 entry, got \(entryCount)\n", stderr)
            return
        }

        guard let entryType = readString(&buffer) else {
            fputs("could not decode buffer contents\n", stderr)
            return
        }

        if entryType != type {
            fputs("wrong MIME type: wanted \(type), got \(entryType)\n", stderr)
            return
        }

        guard let contents = readString(&buffer) else {
            fputs("could not decode buffer contents\n", stderr)
            return
        }

        print(contents)
    }
}
