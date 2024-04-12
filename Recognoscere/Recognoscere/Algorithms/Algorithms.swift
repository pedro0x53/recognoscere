//
//  Algorithm.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 11/04/24.
//

import Foundation

public enum Algorithm: Int, CaseIterable {
    case linearRegression
    case linearLogisticRegression
    case stochasticLinearRegression
    case stochasticLogisticRegression
// TODO: case polinomialRegression
    case gaussianNaiveBayes
// TODO: case KNN
}
