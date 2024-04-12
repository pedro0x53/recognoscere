//
//  Matrix.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 29/03/24.
//

import Foundation
import Accelerate
import Darwin

public class Matrix {
    public private(set) var matrix: [[Float]]
    public private(set) var flatMatrix: [Float] = []
    private var length: Int = 0
    private var stride: Int = 0

    var minValues: [Float] = []
    var maxValues: [Float] = []
    
    public var rows: Int {
        return matrix.count
    }
    
    public var columns: Int {
        return matrix.first?.count ?? 0
    }
    
    public var identityMatrix: Matrix {
        guard rows == columns else {
            fatalError("Identity matrix can only be created for square matrices")
        }
        
        var identity: [Float] = Array(repeating: 0.0, count: rows * columns)
        for i in 0..<rows {
            identity[i * columns + i] = 1.0
        }
        
        return Matrix(matrix: identity, rows: rows, columns: columns)
    }

    public var mainDiagonal: Matrix {
        guard rows == columns else {
            fatalError("Main diagonal can only be created for square matrices")
        }

        var diagonal: [Float] = []
        for index in 0..<rows {
            diagonal.append(self.matrix[index][index])
        }

        return Matrix(matrix: [diagonal])
    }

    public var mean: Float {
        self.sumRows()
            .sumColumns()
            .divide(Float(self.rows * self.columns))
            .flatMatrix.first!
    }

    public var variance: Float {
        let mean = self.mean
        return self.subtract(mean)
                   .pow()
                   .sumRows()
                   .sumColumns()
                   .divide(Float(self.rows * self.columns))
                   .flatMatrix.first!
    }

    public var standadDeviation: Float {
        Darwin.sqrt(self.variance)
    }
    
    public init(matrix: [[Float]]) {
        self.matrix = matrix
        flattenMatrix()
    }
    
    public init(matrix: [Float], rows: Int, columns: Int) {
        self.matrix = Swift.stride(from: 0, to: matrix.count, by: columns).map {
            Array(matrix[$0..<Swift.min($0 + columns, matrix.count)])
        }
        self.flatMatrix = matrix
        self.length = matrix.count
        self.stride = columns
    }

    func setRow(at index: Int, _ sequence: [Float]) {
        self.matrix[index] = sequence
    }

    func set(minValues: [Float], maxValues: [Float]) {
        self.minValues = minValues
        self.maxValues = maxValues
    }
    
    private func flattenMatrix() {
        flatMatrix = matrix.flatMap { $0 }
        length = flatMatrix.count
        stride = columns
    }
    
    private func validateDimensions(with other: Matrix) -> Bool {
        return rows == other.rows && columns == other.columns
    }
    
    private func performOperation(with other: Matrix,
                                  operation: (UnsafePointer<Float>, vDSP_Stride,
                                              UnsafePointer<Float>, vDSP_Stride,
                                              UnsafeMutablePointer<Float>, vDSP_Stride,
                                              vDSP_Length) -> Void) throws -> Matrix {
        guard validateDimensions(with: other) else { throw Matrix.Exception.incompatibleMatrices }
        
        var result = Array(repeating: Float(0.0), count: length)
        operation(flatMatrix, 1, other.flatMatrix, 1, &result, 1, vDSP_Length(length))
        
        return Matrix(matrix: result, rows: rows, columns: columns)
    }
    
    public func sum(with other: Matrix) throws -> Matrix {
        return try performOperation(with: other) { vDSP_vadd($0, 1, $2, 1, $4, 1, $6) }
    }

    public func sum(_ scalar: Float) -> Matrix {
        let result = vDSP.add(scalar, flatMatrix)
        return Matrix(matrix: result, rows: rows, columns: columns)
    }

    public func subtract(_ scalar: Float) -> Matrix {
        let result = vDSP.add(scalar * -1 , flatMatrix)
        return Matrix(matrix: result, rows: rows, columns: columns)
    }
    
    public func subtract(with other: Matrix) throws -> Matrix {
        return try performOperation(with: other) { vDSP_vsub($2, 1, $0, 1, $4, 1, $6) }
    }

    public func subtract(fromRows rowMatrix: Matrix) throws -> Matrix {
        guard rowMatrix.rows == 1 && rowMatrix.columns == self.columns
        else { throw Matrix.Exception.incompatibleRows }

        let result = self.matrix.map { row in
            var result = Array(repeating: Float(0), count: length)
            vDSP_vsub(rowMatrix.flatMatrix, 1, row, 1, &result, 1, vDSP_Length(self.columns))
            return result
        }

        return Matrix(matrix: result)
    }
    
    public func dot(_ scalar: Float) -> Matrix {
        var result = flatMatrix
        var scalarValue = scalar
        vDSP_vsmul(result, 1, &scalarValue, &result, 1, vDSP_Length(length))
        return Matrix(matrix: result, rows: rows, columns: columns)
    }
    
    public func dot(_ other: Matrix) throws -> Matrix {
        guard columns == other.rows else { throw Matrix.Exception.incompatibleMatrices }
        
        var result = Array(repeating: Float(0.0), count: rows * other.columns)
        vDSP_mmul(flatMatrix, 1, other.flatMatrix, 1, &result, 1, vDSP_Length(rows), vDSP_Length(other.columns), vDSP_Length(columns))
        
        return Matrix(matrix: result, rows: rows, columns: other.columns)
    }

    public func divide(_ scalar: Float) -> Matrix {
        guard scalar != 0 else {
            fatalError("Cannot divide by zero.")
        }

        return self.dot(1 / scalar)
    }

    public func divide(_ other: Matrix) throws -> Matrix {
        guard self.rows == other.rows && self.columns == other.columns
        else { throw Matrix.Exception.incompatibleMatrices }

        let result = vDSP.divide(self.flatMatrix, other.flatMatrix)

        return Matrix(matrix: result, rows: self.rows, columns: self.columns)
    }
    
    public func shuffle() {
        matrix.shuffle()
        flattenMatrix()
    }

    public func transpose() -> Matrix {
        var transposedData = Array(repeating: Float(0.0), count: rows * columns)
        vDSP_mtrans(flatMatrix, 1, &transposedData, 1, vDSP_Length(columns), vDSP_Length(rows))
        return Matrix(matrix: transposedData, rows: columns, columns: rows)
    }

    public func sqrt() -> Matrix {
        return Matrix(matrix: vForce.sqrt(self.flatMatrix), rows: self.rows, columns: self.columns)
    }

    public func pow(_ exponent: Float = 2) -> Matrix {
        let exponents = [Float](repeating: exponent, count: self.flatMatrix.count)

        return Matrix(matrix: vForce.pow(bases: self.flatMatrix, exponents: exponents),
                      rows: self.rows,
                      columns: self.columns)
    }

    public func exp() -> Matrix {
        Matrix(matrix: vForce.exp(self.flatMatrix),
                      rows: self.rows,
                      columns: self.columns)
    }

    public func log() -> Matrix {
        Matrix(matrix: vForce.log10(self.flatMatrix),
                      rows: self.rows,
                      columns: self.columns)
    }

    public func sigm() -> Matrix {
        var sigmoid = [Float](repeating: 0, count: flatMatrix.count)
        let ones = [Float](repeating: 1, count: flatMatrix.count)
        
        let exponential = self.dot(-1).exp().sum(1)
        
        vDSP_vdiv(exponential.flatMatrix, 1,
                  ones, 1,
                  &sigmoid, 1,
                  vDSP_Length(flatMatrix.count))

        return Matrix(matrix: sigmoid, rows: rows, columns: columns)
    }

    public func meanByColumn() -> Matrix {
        self.sumRows().divide(Float(self.rows))
    }

    public func sumRows() -> Matrix {
        var result = [Float](repeating: 0, count: self.columns)

        for row in matrix {
            vDSP_vadd(result, 1, row, 1, &result, 1, vDSP_Length(self.columns))
        }

        return Matrix(matrix: [result])
    }

    public func sumColumns() -> Matrix {
        self.transpose().sumRows().transpose()
    }
}
