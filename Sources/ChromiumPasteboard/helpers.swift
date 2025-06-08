import Foundation
import NIO

func writeInt32(_ buffer: inout ByteBuffer, _ int: UInt32) {
    buffer.writeInteger(UInt32(int), endianness: .little)
}

func writeInt16(_ buffer: inout ByteBuffer, _ int: UInt16) {
    buffer.writeInteger(UInt16(int), endianness: .little)
}

func writeString(_ buffer: inout ByteBuffer, _ string: String) {
    let data = string.data(using: .utf16LittleEndian)!
    writeInt32(&buffer, UInt32(data.count / 2)) // divide by 2 because UTF-16 uses 2 bytes per character
    buffer.writeBytes(data)
    writeInt16(&buffer, 0) // write zero char at end
}

func readInt32(_ buffer: inout ByteBuffer) -> UInt32? {
    buffer.readInteger(endianness: .little, as: UInt32.self)
}

func readInt16(_ buffer: inout ByteBuffer) -> UInt16? {
    buffer.readInteger(endianness: .little, as: UInt16.self)
}

func readString(_ buffer: inout ByteBuffer) -> String? {
    guard let length = readInt32(&buffer) else {
        return nil
    }

    guard let bytes = buffer.readBytes(length: Int(length * 2)) else {
        return nil
    }

    let data = Data(bytes)

    // advance over zero char
    _ = readInt16(&buffer)

    return String(data: data, encoding: .utf16LittleEndian)
}
