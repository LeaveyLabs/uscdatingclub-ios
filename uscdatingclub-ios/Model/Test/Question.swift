//
//  Question.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/15.
//

import Foundation

struct Question: Codable {
    let id: Int
    let header: String
    let prompt: String
    let isNumerical: Bool
    let isMultipleAnswer: Bool
    let textAnswerChoices: [String]?
}

typealias TestPageHeader = String

struct TestPage {
    let header: TestPageHeader
    let questions: [Question]
}
