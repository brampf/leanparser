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

@propertyWrapper public final class Transient<Parent: ReadableElement, Value: ReadableElement> {
    
    let uuid: UUID = UUID()
    
    var bound : KeyPath<Parent,Value>
    
    public var wrappedValue: Value
    
    public init(wrappedValue initialValue: Value, _ bound: KeyPath<Parent,Value>){
        self.bound = bound
        self.wrappedValue = initialValue
    }
}

extension Transient : ReadableWrapper {
    
    func read(_ symbol: String?, from bytes: UnsafeRawBufferPointer, in context: inout Context) throws {
        
        if let value : Value = try Value.new(bytes, with: &context, symbol){
            // store in context to access later
            context[uuid] = value
        }
        
    }
    
    func debugLayout(_ level: Int = 0) -> String {
        wrappedValue.debugLayout(level+1)
    }
    
    
}