// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

/// Queue data structure
class Queue<T>: CustomStringConvertible {

    /// The internal list of elements
    private var array: [T] = []

    /// Enqueue element
    func enqueue(_ element: T) {
        array.append(element)
    }

    /// Enqueue elements
    func enqueue(_ elements: [T]) {
        array.append(contentsOf: elements)
    }

    /// Dequeue the first element
    func dequeue() -> T? {
        if !array.isEmpty {
            return array.removeFirst()
        } else {
            return nil
        }
    }

    /// Peek the topmost element, but do not remove it
    func peek() -> T? {
        if !array.isEmpty {
            return array[0]
        } else {
            return nil
        }
    }

    /// To string
    var description: String {
        let elements = array.map {
            "\($0)"
        }.joined(separator: "\n")
        return "\n---Queue-of-'\(String(describing: T.self))'---\n\(elements)\n------------------"
    }

}
