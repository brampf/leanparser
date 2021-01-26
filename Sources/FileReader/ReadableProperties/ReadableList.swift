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

@propertyWrapper public final class ReadableList<F: FixedWidthInteger> : ReadableProperty {
    
    public var length : Int? = nil
    
    public var wrappedValue : [F] = []
    
    public init() {
        //
    }
    
    public init(len: Int){
        self.length = len
    }
    
    public init(len: Int, wrappedValue: [F]){
        self.length = len
        self.wrappedValue = wrappedValue
    }

}

extension ReadableList {
    
    public func read(_ data: UnsafeRawBufferPointer, context: inout Context, _ symbol: String?) throws {
        
        if let len = length {
            // fixed length
            wrappedValue = try data.read(&context.offset, len: len, symbol)
            
        } else if let end = context.head?.endOffset {
            // end of box
            wrappedValue = try data.read(&context.offset, upperBound: end, symbol)
        } else {
            // end of file
            wrappedValue = try data.read(&context.offset, upperBound: data.count, symbol)
        }
    
    }
    
    public var byteSize: Int {
        MemoryLayout<F>.size * wrappedValue.count
    }
    
    
}
