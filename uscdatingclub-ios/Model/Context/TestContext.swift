//
//  TestContext.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/04.
//

import Foundation


struct TestContext {
    static var testResponses: [Int:Any] = [:]
    static var isFirstTest: Bool = false

    static func reset() {
        testResponses = [:]
        isFirstTest = false
    }
}
