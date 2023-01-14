//
//  SurveyResponse.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/12.
//

import Foundation

struct SurveyResponse: Codable {
    let questionId: Int
    let answer: String
}

struct PostSurveyAnswersParams: Codable {
    let email: String
    let responses: [SurveyResponse]
}
