//
//  LinkedList.swift
//  Intelligent Fitness
//
//  Created by Steven Lord on 07/08/2019.
//  Copyright © 2019 Steven Lord. All rights reserved.
//

import Foundation

public struct LinkedList<T> {
    private var head: Node<T>?
    private var tail: Node<T>?
    
    public init() { }
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node<T>? {
        return head
    }
    
    public mutating func append(_ value: T) {
        let newNode = Node(value: value)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    public mutating func remove(_ node: Node<T>) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    public func array() -> [T]{
        var result = [T]()
        
        var node = head
        while node != nil{
            result.append(node!.value)
            node = node!.next
        }
        
        return result
    }
    
}

public class Node<T> {
    public var value: T
    public var next: Node<T>?
    public var previous: Node<T>?
    
    public init(value: T) {
        self.value = value
    }
}
