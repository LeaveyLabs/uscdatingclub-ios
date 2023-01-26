//
//  SurveyResponse.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/12.
//

import Foundation

struct SurveyResponse: Codable, Hashable, Equatable {
    let questionId: Int
    let answer: String
    
    //Equatable
    static func == (lhs: SurveyResponse, rhs: SurveyResponse) -> Bool { return lhs.questionId == rhs.questionId && lhs.answer == rhs.answer }
    
    //Hashable
    func hash(into hasher: inout Hasher) { hasher.combine(questionId) }
}

struct PostSurveyAnswersParams: Codable {
    let email: String
    let responses: [SurveyResponse]
}
