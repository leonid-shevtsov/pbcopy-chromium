import AppKit
import Foundation
import NIO
import NIOFoundationCompat

public enum ChromiumPasteboard {
    public static let pasteboardType = NSPasteboard.PasteboardType("org.chromium.web-custom-data")

    /// Write content to the Chromium pasteboard
    /// - Parameters:
    ///   - content: The data content to write
    ///   - type: The MIME type of the content
    public static func write(_ content: Data, type: String) {
        var buffer = ByteBuffer()

        // Entry count
        writeInt32(&buffer, 1)
        // The only entry
        writeString(&buffer, type)
        writeData(&buffer, content)

        var bufferWithLength = ByteBuffer()

        // Payload size before payload
        writeInt32(&bufferWithLength, UInt32(buffer.readableBytes))
        bufferWithLength.writeBuffer(&buffer)

        let data = bufferWithLength.readData(length: bufferWithLength.readableBytes)!

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setData(data, forType: Self.pasteboardType)
    }

    /// Read content from the Chromium pasteboard
    /// - Parameter type: The expected MIME type of the content
    /// - Returns: The read content if available and of the correct type
    /// - Throws: An error if the content is not available or of the wrong type
    public static func read(type: String) throws -> Data {
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

        guard let contents = readData(&buffer) else {
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

// Helper functions
private func writeInt32(_ buffer: inout ByteBuffer, _ value: UInt32) {
    buffer.writeInteger(value, endianness: .little)
}

private func writeString(_ buffer: inout ByteBuffer, _ string: String) {
    let data = string.data(using: .utf8)!
    writeData(&buffer, data)
}

private func writeData(_ buffer: inout ByteBuffer, _ data: Data) {
    buffer.writeInteger(UInt32(data.count), endianness: .little)
    buffer.writeBytes(data)
}

private func readInt32(_ buffer: inout ByteBuffer) -> UInt32? {
    return buffer.readInteger(endianness: .little, as: UInt32.self)
}

private func readString(_ buffer: inout ByteBuffer) -> String? {
    guard let data = readData(&buffer) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}

private func readData(_ buffer: inout ByteBuffer) -> Data? {
    guard let length = buffer.readInteger(endianness: .little, as: UInt32.self),
          let data = buffer.readBytes(length: Int(length))
    else {
        return nil
    }
    return Data(data)
}
