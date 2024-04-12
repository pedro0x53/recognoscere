//
//  StatisticalExceptions.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 10/04/24.
//

import Foundation

extension Statistical {
    enum Exception: Error {
        case noMeanDefined(Float)
        case noCovarianceDefined(Float)
        case noProbabilityDefined(Float)
    }
}
