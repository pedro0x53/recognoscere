//
//  DataSource.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 31/03/24.
//

import Foundation
import Accelerate

public class DataSource {
    private(set) var matrix: Matrix
    
    public init(fileName: String, fileExtension: String) {
        // Load data from CSV file
        do {
            let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
            let csvData = try String(contentsOf: fileURL!)
            let rows = csvData.components(separatedBy: "\n")
            var matrixData = [[Float]]()
            for row in rows {
                if row.isEmpty { continue }
                let columns = row.components(separatedBy: ",")
                let rowData = columns.compactMap { Float($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                matrixData.append(rowData)
            }

            self.matrix = Matrix(matrix: matrixData)
        } catch {
            fatalError("Failed to load data from CSV file.")
        }
    }
    
    public func getTraining(using method: SamplingMethod = .holdOut) -> Matrix {
        switch method {
        case .holdOut:
            let trainingRowCount = Int(Float(matrix.rows) * 0.8)
            let rows = Array(matrix.flatMatrix.dropLast((matrix.rows - trainingRowCount) * matrix.columns))
            return Matrix(matrix: rows, rows: trainingRowCount, columns: matrix.columns)
        case .kFold(let numberOfChunks, let nthChunk):
            let chunkSize = matrix.rows / numberOfChunks
            let startIndex = (nthChunk - 1) * chunkSize
            let endIndex = Swift.min(nthChunk * chunkSize, matrix.rows)
            let nthRage = startIndex..<endIndex
            let trainingData = matrix.matrix.enumerated().filter { !nthRage.contains($0.offset) }.map { $0.element }
            return Matrix(matrix: trainingData)
        }
    }
    
    public func getTesting(using method: SamplingMethod = .holdOut) -> Matrix {
        switch method {
        case .holdOut:
            let trainingRowCount = Int(Float(matrix.rows) * 0.8)
            let testingData = Array(matrix.flatMatrix.dropFirst(trainingRowCount * matrix.columns))
            return Matrix(matrix: testingData, rows: testingData.count / matrix.columns, columns: matrix.columns)
        case .kFold(let numberOfChunks, let nthChunk):
            let chunkSize = matrix.rows / numberOfChunks
            let startIndex = (nthChunk - 1) * chunkSize
            let endIndex = Swift.min(nthChunk * chunkSize, matrix.rows)
            let nthRage = startIndex..<endIndex
            let testingData = matrix.matrix.enumerated().filter { nthRage.contains($0.offset) }.map { $0.element }
            return Matrix(matrix: testingData)
        }
    }

    public func normalize() {
        self.matrix = self.matrix.normalize()
    }

    public func denormalize() {
        self.matrix = self.matrix.denormalize()
    }
}

public extension DataSource {
    enum SamplingMethod {
        case holdOut
        case kFold(Int, Int)
    }
}
