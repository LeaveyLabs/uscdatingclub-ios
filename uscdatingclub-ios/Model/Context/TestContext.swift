//
//  TestContext.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/04.
//

import Foundation


struct TestContext {
    static var testResponses: [Int:Int] = [:]
    
    static func reset() {
        testResponses = [:]
    }
}
