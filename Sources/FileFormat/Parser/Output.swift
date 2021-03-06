/*
 
 Copyright (c) <2020>
 
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

open class Output : CustomStringConvertible {
    
    var msg : String
    var offsetStart : Int?
    var offsetEnd: Int?
    var node : Any.Type?
    
    public required init(_ msg: String, _ at: Int? = nil, _ until: Int? = nil, node: Any.Type? = nil){
        self.msg = msg
        self.offsetStart = at
        self.offsetEnd = until
        self.node = node
    }
    
    public var description: String {
        
        return
            "\(self.node != nil ? "[\(self.node!)] " : "")" + // node
            "[\(type(of: self))] " + // message type
            "\(offsetStart?.description ?? "")\(offsetEnd != nil ? "...\(offsetEnd?.description ?? " ") " : "\(self.offsetStart != nil ? "" : "")") " + // postion
            msg
    }
}

final public class Error : Output {
    
}

final public class Warning : Output {
    
}

final public class Info : Output {
    
}
