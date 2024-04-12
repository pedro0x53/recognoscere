//
//  ConfusionMatrix.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 11/04/24.
//

import Foundation

public class ConfusionMatrix {
    public let trueLabels: [Int]
    public let predictedLabels: [Int]
    public let numberOfClasses: Int

    public private(set) var matrix: [[Int]] = []

    public var truePositives: Int {
        return matrix[1][1]
    }

    public var trueNegatives: Int {
        return matrix[0][0]
    }

    public var falsePositives: Int {
        return matrix[0][1]
    }

    public var falseNegatives: Int {
        return matrix[1][0]
    }

    public init(trueLabels: [Int], predictedLabels: [Int], numberOfClasses: Int) {
        self.trueLabels = trueLabels
        self.predictedLabels = predictedLabels
        self.numberOfClasses = numberOfClasses
        self.matrix = [[Int]](repeating: [Int](repeating: 0, count: numberOfClasses), count: numberOfClasses)
        self.fillMatrix()
    }

    private func fillMatrix() {
        for index in 0..<trueLabels.count {
            let trueLabel = trueLabels[index]
            let predictedLabel = predictedLabels[index]
            matrix[trueLabel][predictedLabel] += 1
        }
    }
}

extension ConfusionMatrix: CustomStringConvertible {
    public var description: String {
        """
        Confusion Matrix:
        \(trueNegatives) \(falsePositives)
        \(falseNegatives) \(truePositives)
        """
    }
}
