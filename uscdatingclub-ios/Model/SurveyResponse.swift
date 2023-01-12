//
//  SurveyResponse.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/12.
//

import Foundation

struct SurveyResponse: Codable {
    let category: Int
    let answer: Int
}

struct PostSurveyAnswersParams: Codable {
    let email: String
    let responses: [SurveyResponse]
}
