import NIO

func writeInt32(_ buffer: inout ByteBuffer, _ int: UInt32) {
    buffer.writeInteger(UInt32(int), endianness: .little)
}

func writeInt16(_ buffer: inout ByteBuffer, _ int: UInt16) {
    buffer.writeInteger(UInt16(int), endianness: .little)
}

func writeString(_ buffer: inout ByteBuffer, _ string: String) {
    let utf16String = string.utf16
    // length
    writeInt32(&buffer, UInt32(utf16String.count))
    // chars
    utf16String.forEach { char in writeInt16(&buffer, char) }
    // zero char
    writeInt16(&buffer, 0)
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

    var chars: [UTF16.CodeUnit] = []

    for _ in 0 ..< length {
        guard let char = readInt16(&buffer) else {
            return nil
        }
        chars.append(char)
    }

    // advance over zero char
    _ = readInt16(&buffer)

    return String(decoding: chars, as: UTF16.self)
}
