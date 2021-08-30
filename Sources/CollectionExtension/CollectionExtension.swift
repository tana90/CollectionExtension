//
//  CollectionExtension.swift
//  Extensions
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Tudor Ana on 06/20/21.
//  Copyright © 2021 Tudor Octavian Ana (TANA). All rights reserved.
//

import Foundation

// MARK: - Array

public extension Array where Element: Equatable {
    
    func equal(to other: [Element]) -> Bool {
        guard self.count == other.count else { return false }
        for e in self {
            guard self.filter({ $0 == e }).count ==
                    other.filter({ $0 == e }).count else {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    func sliced(by dateComponents: Set<Calendar.Component>,
                for key: KeyPath<Element, Date>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
    
    @discardableResult
    mutating func removeAll(_ item: Element) -> [Element] {
        removeAll(where: { $0 == item })
        return self
    }
    
    @discardableResult
    mutating func removeAll(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }
    
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }
    
    func withoutDuplicates() -> [Element] {
        
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}

// MARK: - Set

public extension Set {
    
    var array: [Element] { Array(self) }
}

// MARK: - Collection

public extension Collection {
    
    var fullRange: Range<Index> { startIndex..<endIndex }
}

public extension Collection where Element: BinaryInteger {
    
    var average: Double {
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }
}

public extension Collection where Element: FloatingPoint {
    
    var average: Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
}

public extension Collection where Element: Equatable {
    
    func indices(of item: Element) -> [Index] {
        return indices.filter { self[$0] == item }
    }
}

// MARK: - Sequence

public extension Sequence {
    
    func count(where condition: (Element) throws -> Bool) rethrows -> Int {
        var count = 0
        for element in self where try condition(element) {
            count += 1
        }
        return count
    }
    
    func all(matching condition: (Element) throws -> Bool) rethrows -> Bool {
        return try !contains { try !condition($0) }
    }
    
    func withoutDuplicates<T: Hashable>(transform: (Element) throws -> T) rethrows -> [Element] {
        var set = Set<T>()
        return try filter { set.insert(try transform($0)).inserted }
    }
}

public extension Sequence where Element: Hashable {
    
    var histogram: [Element: Int] {
        self.reduce(into: [:]) { counts, elem in counts[elem, default: 0] += 1 }
    }
}

// MARK: - Dictionary

public extension Dictionary {
    
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
    
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }
    
    static func - <S: Sequence>(lhs: [Key: Value], keys: S) -> [Key: Value] where S.Element == Key {
        var result = lhs
        result.removeAll(keys: keys)
        return result
    }
    
    static func -= <S: Sequence>(lhs: inout [Key: Value], keys: S) where S.Element == Key {
        lhs.removeAll(keys: keys)
    }
    
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }
    
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

public extension Dictionary where Value: Equatable {
    
    func keys(forValue value: Value) -> [Key] {
        return keys.filter { self[$0] == value }
    }
}

public extension Dictionary where Key: StringProtocol {
    
    mutating func lowercaseAllKeys() {
        for key in keys {
            if let lowercaseKey = String(describing: key).lowercased() as? Key {
                self[lowercaseKey] = removeValue(forKey: key)
            }
        }
    }
    
    mutating func uppercaseAllKeys() {
        for key in keys {
            if let uppercaseKey = String(describing: key).uppercased() as? Key {
                self[uppercaseKey] = removeValue(forKey: key)
            }
        }
    }
}
