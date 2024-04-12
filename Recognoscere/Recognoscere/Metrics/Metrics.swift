//
//  Metrics.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 11/04/24.
//

import Foundation

public class Metrics {
    public let confusionMatrix: ConfusionMatrix

    public init(trueLabels: [Int], predictedLabels: [Int], numberOfClasses: Int) {
        self.confusionMatrix = ConfusionMatrix(trueLabels: trueLabels,
                                               predictedLabels: predictedLabels,
                                               numberOfClasses: numberOfClasses)
    }

    public var accuracy: Float {
        let total = confusionMatrix.truePositives  +
                    confusionMatrix.trueNegatives  +
                    confusionMatrix.falsePositives +
                    confusionMatrix.falseNegatives

        if total == 0 { return 0 }
        return Float(confusionMatrix.truePositives + confusionMatrix.trueNegatives) / Float(total)
    }

    public var recall: Float {
        let denominator = confusionMatrix.truePositives + confusionMatrix.falseNegatives
        if denominator == 0 { return 0 }
        return Float(confusionMatrix.truePositives) / Float(denominator)
    }

    public var precision: Float {
        let denominator = confusionMatrix.truePositives + confusionMatrix.falsePositives
        if denominator == 0 { return 0 }
        return Float(confusionMatrix.truePositives) / Float(denominator)
    }

    public var f1Score: Float {
        if recall + precision == 0 { return 0 }
        return 2 * (recall * precision) / (recall + precision)
    }
}

extension Metrics: CustomStringConvertible {
    public var description: String {
        """
        \(confusionMatrix.description)

        Accuracy: \(accuracy)

        Recall: \(recall)

        Precision: \(precision)

        F1-Score: \(f1Score)
        """
    }
}
