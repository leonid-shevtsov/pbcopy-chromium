import AppKit
import Foundation
import NIO
import NIOFoundationCompat

public enum ChromiumPasteboard {
    public static let pasteboardType = NSPasteboard.PasteboardType("org.chromium.web-custom-data")

    /// Write a string to the Chromium pasteboard
    /// - Parameters:
    ///   - content: The string content to write
    ///   - type: The MIME type of the content
    public static func write(_ content: String, type: String) {
        var buffer = ByteBuffer()

        // Entry count
        writeInt32(&buffer, 1)
        // The only entry
        writeString(&buffer, type)
        writeString(&buffer, content)

        var bufferWithLength = ByteBuffer()

        // Payload size before payload
        writeInt32(&bufferWithLength, UInt32(buffer.readableBytes))
        bufferWithLength.writeBuffer(&buffer)

        let data = bufferWithLength.readData(length: bufferWithLength.readableBytes)!

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: Self.pasteboardType)
    }

    /// Read a string from the Chromium pasteboard
    /// - Parameter type: The expected MIME type of the content
    /// - Returns: The read string if available and of the correct type
    /// - Throws: An error if the content is not available or of the wrong type
    public static func read(type: String) throws -> String {
        let pasteboard = NSPasteboard.general
        guard let data = pasteboard.data(forType: Self.pasteboardType) else {
            throw PasteboardError.noData
        }

        var buffer = ByteBuffer(data: data)

        guard readInt32(&buffer) != nil else {
            throw PasteboardError.invalidData
        }

        guard let entryCount = readInt32(&buffer) else {
            throw PasteboardError.invalidData
        }

        if entryCount < 1 {
            throw PasteboardError.invalidEntryCount(Int(entryCount))
        }

        guard let entryType = readString(&buffer) else {
            throw PasteboardError.invalidData
        }

        if entryType != type {
            throw PasteboardError.wrongType(expected: type, got: entryType)
        }

        guard let contents = readString(&buffer) else {
            throw PasteboardError.invalidData
        }

        return contents
    }
}

public enum PasteboardError: Error {
    case noData
    case invalidData
    case invalidEntryCount(Int)
    case wrongType(expected: String, got: String)
}
