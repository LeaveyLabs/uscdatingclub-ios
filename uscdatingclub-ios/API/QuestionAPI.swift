//
//  QuestionAPI.swift
//  uscdatingclub-ios
//
//  Created by Kevin Sun on 1/12/23.
//

import Foundation


//https://github.com/kean/Nuke

struct QuestionError: Codable {
    let question_id: [String]?
    let answer: [String]?
    
    let non_field_errors: [String]?
    let detail: String?
}

class QuestionAPI {
    // Paths to API endpoints
    enum Endpoints: String {
        case getQuestions = "get-questions/"
        case getPageOrder = "get-page-order/"
    }
    
    // Parameters for API
    enum ParameterKeys: String {
        case questionId = "question_id"
        case answer = "answer"
    }
    
    static let QUESTION_RECOVERY_MESSAGE = "try again later"
    
    static func throwAPIError(error: QuestionError) throws {
        if let questionErrors = error.question_id,
            let questionError = questionErrors.first {
            throw APIError.ClientError(questionError, QUESTION_RECOVERY_MESSAGE)
        }
        if let answerErrors = error.answer,
            let answerError = answerErrors.first {
            throw APIError.ClientError(answerError, QUESTION_RECOVERY_MESSAGE)
        }
    }
    
    static func filterQuestionErrors(data:Data, response:HTTPURLResponse) throws {
        let statusCode = response.statusCode
        
        if isSuccess(statusCode: statusCode) { return }
        if isClientError(statusCode: statusCode) {
            let error = try JSONDecoder().decode(QuestionError.self, from: data)
            try throwAPIError(error: error)
        }
        throw APIError.Unknown
    }
    
    static func getQuestions() async throws -> [Question] {
        let url = "\(Env.BASE_URL)\(Endpoints.getQuestions.rawValue)"
        let (data, _) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: Data(), method: HTTPMethods.GET.rawValue)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Question].self, from: data)
    }
    
    static func getPageOrder() async throws -> [String] {
        let url = "\(Env.BASE_URL)\(Endpoints.getQuestions.rawValue)"
        let (data, _) = try await BasicAPI.basicHTTPCallWithoutToken(url: url, jsonData: Data(), method: HTTPMethods.GET.rawValue)
        return try JSONDecoder().decode([String].self, from: data)
    }
}

