//
//  MatrixExceptions.swift
//  Recognoscere
//
//  Created by Pedro Sousa on 25/03/24.
//

import Foundation

extension Matrix {
    enum Exception: String, Error {
        case incompatibleMatrices
        case incompatibleRows
    }
}
