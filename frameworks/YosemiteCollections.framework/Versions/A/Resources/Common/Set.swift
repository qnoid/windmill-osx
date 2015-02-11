//
//  Set.swift
//  Collections
//
//  Created by Markos Charatzas on 01/10/2014.
//  Copyright (c) 2014 qnoid.com. All rights reserved.
//

import Foundation

public class Set<E : Hashable> : SequenceType
{
    var startIndex: Int {
        return self.data.keys.array.startIndex
        }
    
    var endIndex: Int {
        return self.data.keys.array.endIndex
    }
        
    public var isEmpty: Bool {
        return self.data.isEmpty
    }

    public var count: Int {
        return self.data.count
    }

    var data : [E: Bit]
    
    /* class */ let VALUE = Bit.One
    
    public init()
    {
        self.data = [:]
    }
    
    public func add(e: E) -> Bool
    {
        let data = self.data.updateValue(VALUE, forKey:e)
        
    return (data == nil)
    }
    
    public func contains(e: E) -> Bool{
        return (self.data[e] == VALUE)
    }
    
    public func remove(e: E) -> Bool{
        return (self.data.removeValueForKey(e) == VALUE)
    }
    
    public func removeAll() {
        self.data.removeAll(keepCapacity: false)
    }
    
    public func generate() -> SetGenerator<E>
    {
        let values = self.data.keys.array;
        
        return SetGenerator(data: values[0..<values.count])
    }
}

public struct SetGenerator<E> : GeneratorType
{
    var data: Slice<E>
    
    public mutating func next() -> E?
    {
        if(self.data.isEmpty){
            return nil;
        }
        
        let next = self.data[0]
        
        self.data = self.data[1..<data.count];
        
        return next;
    }
}