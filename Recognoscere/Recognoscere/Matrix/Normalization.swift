//
//  Normalization.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 11/04/24.
//

import Foundation

public extension Matrix {
    func normalize() -> Matrix {
        self.minValues = []
        self.maxValues = []

        let transposedMatrix = self.transpose()
        
        let normalizedColumns = transposedMatrix.matrix.map { column in
            let minValue = column.min() ?? 0
            let maxValue = column.max() ?? 0
            let range = maxValue - minValue

            self.minValues.append(minValue)
            self.maxValues.append(maxValue)
           
            guard range != 0
            else { return column }
            
            return column.map { ($0 - minValue) / range }
        }
        
        let normalizedMatrix = Matrix(matrix: normalizedColumns).transpose()
        normalizedMatrix.set(minValues: self.minValues, maxValues: self.maxValues)
        return normalizedMatrix
    }

    func denormalize() -> Matrix {
        let transposedMatrix = self.transpose()
        
        let denormalizedColumns = transposedMatrix.matrix.enumerated().map { index, column in
            column.map { value in
                value * (self.maxValues[index] - self.minValues[index]) + self.minValues[index]
            }
        }
        
        let denormalizedMatrix = Matrix(matrix: denormalizedColumns)
        return denormalizedMatrix.transpose()
    }
}
