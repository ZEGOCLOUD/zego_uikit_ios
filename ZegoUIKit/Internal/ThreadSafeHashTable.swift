//
//  ThreadSafeHashTable.swift
//  ZegoUIKit
//
//  Created by Kael Ding on 2024/5/8.
//

import Foundation

public class ThreadSafeHashTable<T: AnyObject> {
    
    private var hashTable: NSHashTable<T> = NSHashTable(options: .weakMemory)
    private let concurrentQueue = DispatchQueue(label: "HashTable Barrier Queue",
                                                attributes: .concurrent)
    // MARK: Get
    public var count: Int {
        concurrentQueue.sync {
            hashTable.count
        }
    }
    
    public var allObjects: [T] {
        concurrentQueue.sync {
            hashTable.allObjects
        }
    }
    
    public var anyObject: T? {
        concurrentQueue.sync {
            hashTable.anyObject
        }
    }
    
    // create a set of the contents
    public var setRepresentation: Set<AnyHashable> {
        concurrentQueue.sync {
            hashTable.setRepresentation
        }
    }
    
    public func member(_ object: T?) -> T? {
        concurrentQueue.sync {
            hashTable.member(object)
        }
    }
    
    public func contains(_ anObject: T?) -> Bool {
        concurrentQueue.sync {
            hashTable.contains(anObject)
        }
    }
    
    public func intersects(_ other: NSHashTable<T>) -> Bool {
        concurrentQueue.sync {
            hashTable.intersects(other)
        }
    }
    
    public func isEqual(to other: NSHashTable<T>) -> Bool {
        concurrentQueue.sync {
            hashTable.isEqual(to: other)
        }
    }

    public func isSubset(of other: NSHashTable<T>) -> Bool {
        concurrentQueue.sync {
            hashTable.isSubset(of: other)
        }
    }
    
    // MARK: Set
    public func add(_ object: T?) {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.add(object)
        }
    }

    public func remove(_ object: T?) {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.remove(object)
        }
    }

    public func removeAllObjects() {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.removeAllObjects()
        }
    }
    
    public func intersect(_ other: NSHashTable<T>) {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.intersect(other)
        }
    }

    public func union(_ other: NSHashTable<T>) {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.union(other)
        }
    }

    public func minus(_ other: NSHashTable<T>) {
        concurrentQueue.async(flags: .barrier) {
            self.hashTable.minus(other)
        }
    }
}
