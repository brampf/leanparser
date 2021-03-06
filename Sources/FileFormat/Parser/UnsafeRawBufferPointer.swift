

import Foundation

extension UnsafeRawBufferPointer {
    
    public func skip(_ bytes: Int, _ offset: inout Int, _ name : String? = "SKIP") {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, "SKIP \(bytes)" , name ?? "")
        #endif
        
        offset += bytes
    }
}

extension UnsafeRawBufferPointer {
        
    /// Read `FixedWidthInteger`
    public func read<I: FixedWidthInteger>(_ offset: inout Int, byteSwapped : Bool = false, _ name : String? = nil) throws -> I {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, I.self, name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= self.count - MemoryLayout<I>.size else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, I.self, offset), self.count - MemoryLayout<I>.size)
        }
        
        /// access the memory
        guard let val = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: I.self).pointee else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, I.self, offset))
        }
        
        /// move the pointer
        offset += MemoryLayout<I>.size
        /// return the requested value
        return byteSwapped ? val.byteSwapped : val
    }
    
    /// Read `FixedWidthInteger` as another `FixedWidthInteger`
    public func read<I: FixedWidthInteger, J: FixedWidthInteger>(_ offset: inout Int, as: I.Type, byteSwapped : Bool = false, _ name: String? = nil) throws -> J {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, I.self, name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= self.count - MemoryLayout<I>.size else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, I.self, offset), self.count - MemoryLayout<I>.size)
        }
        
        /// access the memory
        guard let val = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: I.self).pointee else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, I.self, offset))
        }
        
        /// move the pointer
        offset += MemoryLayout<I>.size
        /// return the requested value
        return J(byteSwapped ? val.byteSwapped : val)
    }

}
    
// MARK:- String
extension UnsafeRawBufferPointer {
    
    /// Read zero-terminated CString
    public func read(_ offset: inout Int, upperBound: Int, _ name: String? = nil) throws -> String {
    
        #if PARSER_RAW_TRACE
        debugOut(offset, String.self, name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < self.count else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, String.self, offset), self.count)
        }
        
        let bounded = self.bindMemory(to: CChar.self)[offset..<upperBound]
        let string = String(cString: Array(bounded))
        
        // move the pointer beyond the null but not beyond the bounds
        offset += Swift.min(string.count + 1, self.count)
        return string
        
    }
    
    /// Read String of known length or until end of buffer
    public func read(_ offset: inout Int, len: Int? = nil, encoding: String.Encoding = .utf8, _ name: String? = nil) throws -> String? {
        
        let bytes = len ?? self.count - offset
        
        #if PARSER_RAW_TRACE
        debugOut(offset, "String \(bytes)", name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= self.count - bytes else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, String.self, offset),self.count-bytes)
        }
        
        let data = Data(self[offset..<offset+bytes])
        
        // move the pointer beyond the null but not beyond the bounds
        offset += bytes
        return String(data: data, encoding: encoding)
        
    }
}

// MARK:- Array
extension UnsafeRawBufferPointer {
    
    /// Read Array  of known length or until end of buffer
    public func read<F: FixedWidthInteger>(_ offset: inout Int, len: Int, byteSwapped : Bool = false, _ name: String? = nil) throws -> [F] {
   
        #if PARSER_RAW_TRACE
        debugOut(offset, "\(F.self) [\(len)]", name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && (offset + len * MemoryLayout<F>.size) <= self.count else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, [F].self, offset), self.count)
        }
        
        /// access the memory
        guard var val = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: F.self) else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, [F].self, offset))
        }
        
        var result = [F]()
        for _ in 0..<len {
            result.append(byteSwapped ? val.pointee.byteSwapped : val.pointee)
            val = val.predecessor()
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += result.count * MemoryLayout<F>.size
        return result
        
    }
    
    /// Read Array  of known length or until end of buffer
    public func read<F: FixedWidthInteger>(_ offset: inout Int, upperBound: Int, byteSwapped : Bool = false, _ name: String? = nil) throws -> [F] {
        
        guard (upperBound-offset) % MemoryLayout<F>.size == 0 else {
            print("\(upperBound-offset) incompatible length for Array of \(F.self)")
            throw ReaderError.missalignedData(ErrorStack(name, [F].self, offset), upperBound-offset)
        }
        
        let len = (upperBound-offset) / MemoryLayout<F>.size

        #if PARSER_RAW_TRACE
        debugOut(offset, "\([F].self) [\(len)]", name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= upperBound else {
            print("Reading \(F.self)[\(len)] at \(offset) outside the bounds of [0...\(self.count-1)]")
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, [F].self, offset), upperBound)
        }
        
        var result = [F]()
        for idx in 0..<len {
            let position = offset + idx * MemoryLayout<F>.size
            if let val = self.baseAddress?.load(fromByteOffset: position  , as: F.self) {
                result.append(byteSwapped ? val.byteSwapped : val)
            } else {
                /// - ToDo: Better throw error?
                result.append(.zero)
            }
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += result.count * MemoryLayout<F>.size
        return result
        
    }
}

// MARK:- Data
extension UnsafeRawBufferPointer {
    
    /// Read Data  of known length or until end of buffer
    public func read(_ offset: inout Int, upperBound: Int, byteSwapped : Bool = false, _ name: String? = nil) throws -> Data? {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, "\(Data.self) [\(upperBound-offset)]", name)
        #endif
        
        if offset == upperBound {
            return nil
        }
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset < upperBound else {
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, Data.self, offset), upperBound)
        }
        
        print("DATA: \(upperBound-offset) - \(self.count)")
        
        /// access the memory
        let result = Data(self[offset..<upperBound])
        
        // move the pointer beyond the null but not beyond the bounds
        offset += result.count
        return result
        
    }
}

//MARK:- Enum / RawRepresentable
extension UnsafeRawBufferPointer {
    
    /// Read `RawRepresentable`
    public func read<Raw: RawRepresentable>(_ offset: inout Int, _ name: String? = nil) throws -> Raw? {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, Raw.self, name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= self.count - MemoryLayout<Raw.RawValue>.size else {
            print("Reading \(MemoryLayout<Raw.RawValue>.size) byte at \(offset) outside the bounds of [0...\(self.count-1)]")
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, Raw.RawValue.self, offset), self.count - MemoryLayout<Raw.RawValue>.size)
        }
        
        guard let raw = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: Raw.RawValue.self).pointee else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, Raw.RawValue.self, offset))
        }
        
        guard let value = Raw(rawValue: raw) else {
            throw ReaderError.wrongDataType(ErrorStack(name, Raw.RawValue.self, offset))
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += MemoryLayout<Raw.RawValue>.size
        return value
        
    }
    
    /// Read `RawRepresentable`
    public func read<Raw: RawRepresentable>(_ offset: inout Int, byteSwapped : Bool = false, _ name : String? = nil) throws -> Raw? where Raw.RawValue : FixedWidthInteger {
        
        #if PARSER_RAW_TRACE
        debugOut(offset, Raw.self, name)
        #endif
        
        // make sure that the offset is within the allowed bounds
        guard offset >= 0 && offset <= self.count - MemoryLayout<Raw.RawValue>.size else {
            print("Reading \(MemoryLayout<Raw.RawValue>.size) byte at \(offset) outside the bounds of [0...\(self.count-1)]")
            throw ReaderError.invalidMemoryAddress(ErrorStack(name, Raw.self, offset), self.count - MemoryLayout<Raw.RawValue>.size)
        }
        
        guard let raw = self.baseAddress?.advanced(by: offset).assumingMemoryBound(to: Raw.RawValue.self).pointee else {
            throw ReaderError.incompatibleDataFormat(ErrorStack(name, Raw.self, offset))
        }
        
        guard let value = Raw(rawValue: byteSwapped ? raw.byteSwapped : raw) else {
            throw ReaderError.wrongDataType(ErrorStack(name, Raw.self, offset))
        }
        
        // move the pointer beyond the null but not beyond the bounds
        offset += MemoryLayout<Raw.RawValue>.size
        return value
        
    }
}

#if PARSER_RAW_TRACE
extension UnsafeRawBufferPointer {
    
    func debugOut(_ offset: Int, _ type: Any.Type, _ debugSymbol: String? = nil) {
        debugOut(offset, String(describing: type), debugSymbol)
    }
    
    func debugOut(_ offset: Int, _ type: String, _ debugSymbol: String? = nil) {
        let offset = String(offset).padding(toLength: 13, withPad: " ", startingAt: 0)
        let symbol = "\(debugSymbol ?? "")".padding(toLength: 12, withPad: " ", startingAt: 0)
        let type = "\(type)".padding(toLength: 12, withPad: " ", startingAt: 0)
        
        print("[\(offset)]      \(symbol) : \(type)")
    }
    
}
#endif
