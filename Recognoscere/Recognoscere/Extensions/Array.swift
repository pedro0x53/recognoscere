//
//  Array.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 30/03/24.
//

import Foundation

public extension Array {
    func merge(with sequence: [Self.Element]) -> [[Self.Element]] {
        guard self.count == sequence.count else {
            fatalError("Arrays must have the same number of elements")
        }
        
        var result = [[Self.Element]]()
        for i in 0..<self.count {
            result.append([self[i], sequence[i]])
        }
        return result
    }
}
