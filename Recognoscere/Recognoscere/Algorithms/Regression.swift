//
//  Regression.swift
//  recognoscere
//
//  Created by Pedro Sousa on 18/02/24.
//

import Foundation
import Accelerate

public class Regression {
    public private(set) var data: Matrix
    public private(set) var features: Matrix
    public private(set) var output: Matrix
    public private(set) var parameters: Matrix
    public private(set) var learningRate: Float
    public private(set) var epochs: Int

    public var isLogistic: Bool = false
    public var isStochastic: Bool = false

    private var interceptor: Float = 1
    
    public init(data: [[Float]], learningRate: Float, epochs: Int) {
        self.data = Matrix(matrix: data)
        self.parameters = Matrix(matrix: [[Float]](repeating: [Float](repeating: 1, count: 1),
                                                   count: data[0].count))

        var rawFeatures: [[Float]] = []
        var rawOutput: [[Float]] = []

        for pattern in self.data.matrix {
            rawOutput.append([pattern.last!])
            rawFeatures.append([1] + pattern.dropLast())
        }

        self.output = Matrix(matrix: rawOutput)
        self.features = Matrix(matrix: rawFeatures)

        self.learningRate = learningRate
        self.epochs = epochs
    }

    private func calculateErrors(given predictions: Matrix) throws -> Matrix {
        if isLogistic {
            return try output.subtract(with: predictions.sigm())
        } else {
            return try output.subtract(with: predictions)
        }
    }
    
    private func gradientDescent() throws {
        for _ in 0..<epochs {
            let predictions = try features.dot(parameters)
            let errors = try self.calculateErrors(given: predictions)
            let gradients = try features.transpose()
                                        .dot(errors)
                                        .dot(learningRate / Float(features.rows))

            
            parameters = try parameters.sum(with: gradients)
        }
    }
    
    public func fit() throws {
        try gradientDescent()
    }

    public func predict(_ inputMatrix: Matrix) throws -> (expected: Matrix, actual: Matrix) {
        var rawFeatures: [[Float]] = []
        var rawOutput: [[Float]] = []

        for pattern in inputMatrix.matrix {
            rawOutput.append([pattern.last!])
            rawFeatures.append([1] + pattern.dropLast())
        }

        let output = Matrix(matrix: rawOutput)
        let features = Matrix(matrix: rawFeatures)

        let actual = try features.dot(parameters)
        return (output, actual)
    }
}
