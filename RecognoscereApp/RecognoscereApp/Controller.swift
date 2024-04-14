//
//  Controller.swift
//  RecognoscereApp
//
//  Created by Pedro Sousa on 18/02/24.
//

import SwiftUI
import Recognoscere

@Observable
class Controller {
    @ObservationIgnored static let data = Sampling(fileName: "iris")

    func run() {
//        self.holdOut(shouldNormalize: true)
//        self.kFold(numberOfChunks: 10, shouldNormalize: true)
        self.kNearestNeighbor()
    }

    private func kNearestNeighbor(shouldNormalize: Bool = false) {
        Controller.data.shuffle()

        if shouldNormalize {
            Controller.data.normalize()
        }

        let trainingData = Controller.data.getTraining().matrix
        let testingData = Controller.data.getTesting().matrix
        
        let knn = KNN(neighbors: testingData)

        do {
            let predictions = try knn.predict(testingData, numberOfNeighbours: 3)
            print("Expected: \(predictions.expected)")
            print("Actual: \(predictions.actual)")
        } catch {
            print(error.localizedDescription)
        }
    }

    private func holdOut(shouldNormalize: Bool = false) {
        print("Hold Out\n")

        let trainingData = Controller.data.getTraining()
        let testingData = Controller.data.getTesting()
        
        let metrics = self.training(trainingData: trainingData, testingData: testingData)

        print(metrics.description)
    }

    private func kFold(numberOfChunks: Int, shouldNormalize: Bool = false) {
        print("K-Fold\n")

        var kMetrics: [Metrics] = []

        for fold in 1...numberOfChunks {
            Controller.data.normalize()

            let trainingData = Controller.data.getTraining(using: .kFold(10, fold))
            let testingData = Controller.data.getTesting(using: .kFold(10, fold))

            Controller.data.denormalize()

            let metrics = self.training(trainingData: trainingData, testingData: testingData)
            kMetrics.append(metrics)
        }

        let accuracies = Matrix(matrix: [kMetrics.map{ $0.accuracy }])
        let recalls = Matrix(matrix: [kMetrics.map{ $0.recall }])
        let precisions = Matrix(matrix: [kMetrics.map{ $0.precision }])
        let f1Scores = Matrix(matrix: [kMetrics.map{ $0.f1Score }])

        print("Accuracy Mean: \(accuracies.mean)")
        print("Accuracy Standard Deviation: \(accuracies.standadDeviation)")
        print("\n")

        print("Recall Mean: \(recalls.mean)")
        print("Recall Standard Deviation: \(recalls.standadDeviation)")
        print("\n")

        print("Precision Mean: \(precisions.mean)")
        print("Precision Standard Deviation: \(precisions.standadDeviation)")
        print("\n")

        print("F1-Score Mean: \(f1Scores.mean)")
        print("F1-Score Standard Deviation: \(f1Scores.standadDeviation)")
        print("\n")
    }

    private func training(trainingData: Matrix, testingData: Matrix) -> Metrics {
        let statistical = Statistical(data: trainingData.matrix)
        
        do {
            try statistical.fit()
            let testingResult = try statistical.predict(testingData)

            return Metrics(trueLabels: testingResult.expected.flatMatrix.map { Int($0) },
                           predictedLabels: testingResult.actual.flatMatrix.map { Int($0) },
                           numberOfClasses: 2)
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
