//
//  KNN.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 14/04/24.
//

import Foundation

public class KNN {
    public private(set) var neighbors: [DataPoint<Float>] = []

    public init(neighbors: [[Float]]) {
        self.neighbors = KNN.buildDataPoints(from: neighbors)
    }

    public static func buildDataPoints(from matrix: [[Float]]) -> [DataPoint<Float>] {
        var points: [DataPoint<Float>] = []

        for pattern in matrix {
            let label = pattern.last!
            let features = Array(pattern.dropLast())
            points.append(DataPoint(label: label, data: features))
        }

        return points
    }

    public func predict(_ inputMatrix: [[Float]], numberOfNeighbours: Int) throws -> (expected: [Float], actual: [Float]) {
        let dataPoints = KNN.buildDataPoints(from: inputMatrix)
        let expected: [Float] = dataPoints.map { $0.label }

        let patterns: [[Float]] = dataPoints.map { $0.data }
        let actual = try patterns.map { try self.predict(pattern: $0, numberOfNeighbours: numberOfNeighbours) }

        return (expected, actual)
    }

    private func predict(pattern: [Float], numberOfNeighbours: Int) throws -> Float {
        let sortedData = try self.neighbors.sorted(by: { pointA, pointB in
            (try self.euclideanDistace(pattern, pointA.data)) < (try self.euclideanDistace(pattern, pointB.data))
        })

        var label = sortedData.first!.label

        var labelCounts: [Float: Int] = [:]
        for neighbor in sortedData {
            if let count = labelCounts[neighbor.label] {
                labelCounts[neighbor.label] = count + 1
            } else {
                labelCounts[neighbor.label] = 1
            }

            if labelCounts[neighbor.label] == numberOfNeighbours {
                label = neighbor.label
                break
            }
        }

        return label
    }

    private func euclideanDistace(_ lhs: [Float], _ rhs: [Float]) throws -> Float {
        guard lhs.count == rhs.count
        else { throw Matrix.Exception.incompatibleRows }

        let lhsMatrix = Matrix(matrix: [lhs])
        let rhsMatrix = Matrix(matrix: [rhs])

        let summation = try lhsMatrix.subtract(with: rhsMatrix)
                                     .pow()
                                     .sumColumns()
                                     .flatMatrix.first!
        return sqrt(summation)
    }
}
