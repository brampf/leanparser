/*
 
 Copyright (c) <2021>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import Foundation

public struct FixedCharBoundedFrame<F: UnsignedInteger & FixedWidthInteger & AnyReadable> : PersistentFrameReader {
    public typealias Value = String
    
    public var bound : F = .zero
    public var encoding : String.Encoding = .utf8

    
    public func read<C: Context>(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout C) throws -> String? {
        
        let val : F = try bytes.read(&context.offset, byteSwapped: false, symbol)
        
        var me = [val]
        let data = Data(bytes: &me, count: me.count * MemoryLayout<F>.size)
        return String(data: data, encoding: encoding)
    }
    
}

extension Persistent where
    Meta : UnsignedInteger & FixedWidthInteger & AnyReadable,
    Value == String,
    Parent == EmptyFrame,
    Bound == FixedCharBoundedFrame<Meta>
{
    
    convenience public init(wrappedValue initialValue: Bound.Value, _ label: Meta.Type, _ encoding: String.Encoding = .utf8) {
        
        self.init(wrappedValue: initialValue, FixedCharBoundedFrame<Meta>(encoding:  encoding))
    }
}
