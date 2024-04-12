//
//  Statistical.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 10/04/24.
//

import Foundation

public class Statistical {
    public private(set) var data: Matrix
    public private(set) var features: Matrix
    public private(set) var output: Matrix

    public private(set) var categories: [Float] = []

    public private(set) var means: Matrix?
    public private(set) var covariances: [Float: Matrix] = [:]

    private var probabilitiesByCategory: [Float: Float] = [:]

    public init(data: [[Float]]) {
        self.data = Matrix(matrix: data)

        var rawFeatures: [[Float]] = []
        var rawOutput: [[Float]] = []

        for pattern in self.data.matrix {
            rawOutput.append([pattern.last!])
            rawFeatures.append([1] + pattern.dropLast())
        }

        self.output = Matrix(matrix: rawOutput)
        self.features = Matrix(matrix: rawFeatures)
    }

    public func fit() throws {
        self.getCategories()
        self.calculateMeans()
        try self.calculateCovariances()
    }

    public func predict(_ inputMatrix: Matrix) throws -> (expected: Matrix, actual: Matrix) {
        var rawFeatures: [[Float]] = []
        var rawOutput: [Float] = []

        for pattern in inputMatrix.matrix {
            rawOutput.append(pattern.last!)
            rawFeatures.append(pattern.dropLast())
        }

        let features = Matrix(matrix: rawFeatures)

        let expected = Matrix(matrix: [rawOutput])

        var predictions: [Float] = []
        for row in features.matrix {
            let category = try getMostProbableCategory(Matrix(matrix: [row]))
            predictions.append(category)
        }

        return (expected, Matrix(matrix: [predictions]))
    }

    private func getMostProbableCategory(_ inputMatrix: Matrix) throws -> Float {
        var probabilities = [Float](repeating: 0, count: categories.count)

        for (index, category) in categories.enumerated() {
            guard let means = self.means,
                  index <= means.rows
            else { throw Statistical.Exception.noMeanDefined(category) }

            let mean = Matrix(matrix: [means.matrix[index]])

            guard let classProbability = self.probabilitiesByCategory[category]
            else { throw Statistical.Exception.noProbabilityDefined(category) }

            guard let covariance = self.covariances[category]
            else { throw Statistical.Exception.noCovarianceDefined(category) }

            let classLog = log(classProbability)
            let covarianceSum = covariance.dot(2 * .pi).log().sumColumns().flatMatrix.first! / 2
            let featuresFactor = try inputMatrix.subtract(with: mean)
                                                .pow()
                                                .divide(covariance)
                                                .sumColumns()
                                                .flatMatrix.first!

            let probability = classLog - covarianceSum - featuresFactor

            probabilities[index] = probability
        }

        let maxValue = probabilities.max()!

        return categories[probabilities.firstIndex(of: maxValue)!]
    }

    private func getCategories() {
        self.categories = Array(Set(output.flatMatrix)).sorted() // classes
    }

    private func calculateMeans() {
        var rawMeans: [[Float]] = []
        for category in self.categories {
            let patterns = data.matrix.filter { $0.last == Float(category) }
                                      .map { Array($0.dropLast()) }

            rawMeans.append(Matrix(matrix: patterns).meanByColumn().flatMatrix)
            probabilitiesByCategory[category] = Float(patterns.count) / Float(data.rows)
        }

        self.means = Matrix(matrix: rawMeans)
    }

    private func calculateCovariances() throws {
        for (index, category) in self.categories.enumerated() {
            guard let means = self.means,
                  index < (self.means?.rows ?? -1)
            else { throw Statistical.Exception.noMeanDefined(category) }

            let mean = means.matrix[index]
            let patterns = data.matrix.filter { $0.last == Float(category) }
                                      .map { Array($0.dropLast()) }

            let covarianceFactor: Float = 1 / Float((patterns.count - 1))

            let patternMatrix = Matrix(matrix: patterns)
            let meansMatrix = Matrix(matrix: [[Float]](repeating: mean, count: patternMatrix.rows))

            let covariance = try patternMatrix.subtract(with: meansMatrix)
                                              .pow()
                                              .sumRows()
                                              .dot(covarianceFactor)

            self.covariances[category] = covariance
        }
    }
}
