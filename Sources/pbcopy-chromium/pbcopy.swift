import AppKit
import ArgumentParser
import ChromiumPasteboard
import Foundation

@main
struct PbcopyChromium: ParsableCommand {
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

        ChromiumPasteboard.write(contents, type: type)
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
            guard let contents = String(data: contentsData, encoding: .utf8) else {
                fputs("Input is not valid UTF-8\n", stderr)
                return nil
            }
            return contents
        } catch {
            fputs("failed to read input: \(error)\n", stderr)
            return nil
        }
    }

    func runPaste() throws {
        do {
            let contents = try ChromiumPasteboard.read(type: type)
            if let data = contents.data(using: .utf8) {
                FileHandle.standardOutput.write(data)
            } else {
                fputs("Failed to convert string to UTF-8\n", stderr)
            }
        } catch PasteboardError.noData {
            fputs("no data in clipboard, copy something from Chromium first\n", stderr)
        } catch let PasteboardError.wrongType(expected, got) {
            fputs("wrong MIME type: wanted \(expected), got \(got)\n", stderr)
        } catch {
            fputs("error: \(error)\n", stderr)
        }
    }
}
