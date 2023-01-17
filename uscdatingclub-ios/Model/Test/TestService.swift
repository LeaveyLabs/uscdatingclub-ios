//
//  TestService.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/15.
//

import Foundation

class TestService: NSObject {
    
    static var shared = TestService()
    
    private var pageHeaders: [TestPageHeader] = []
    private var pagedQuestions: [TestPageHeader: [Question]] = [:]
    private var responseContext: [Int: Set<SurveyResponse>] = [:]
    
    //MARK: - Initializer
    
    private override init() {
        super.init()
    }
    
    func initialize() {
        Task {
            do {
                try await loadTestQuestions()
            } catch {
                print("error loading test questions", error)
            }
        }
    }
    
    func loadTestQuestions() async throws {
        pageHeaders = try await QuestionAPI.getPageOrder()
        let questions = try await QuestionAPI.getQuestions()
        for question in questions {
            if pagedQuestions.keys.contains(question.header) {
                pagedQuestions[question.header]!.append(question)
            } else {
                pagedQuestions[question.header] = [question]
            }
        }
    }
        
    //MARK: - Getters
    
    func pageCount() -> Int {
        return pageHeaders.count
    }
    
    private func pageIndex(for testPage: TestPage) -> Int? {
        return pageHeaders.firstIndex(of: testPage.header)
    }
    
    func getNextPage(currentPage testPage: TestPage) -> TestPage? {
        guard
            let currentIndex = pageIndex(for: testPage),
            currentIndex < pageHeaders.count-1
        else { return nil }
        
        let nextPageHeader = pageHeaders[currentIndex+1]
        let nextQuestions: [Question] = pagedQuestions[nextPageHeader]!
        return TestPage(header: nextPageHeader, questions: nextQuestions)
    }
    
    func getPage(number: Int) -> TestPage {
        let pageHeader = pageHeaders[number]
        let questions: [Question] = pagedQuestions[pageHeader] ?? []
        return TestPage(header: pageHeader, questions: questions)
    }
    
    func currentResponseFor(_ question: Question) -> SurveyResponse? {
        return responseContext[question.id]?.first
    }
    
    func currentResponsesFor(_ question: Question) -> Set<SurveyResponse> {
        return responseContext[question.id] ?? []
    }
    
    func hasAnswered(_ question: Question) -> Bool {
        return responseContext.keys.contains(question.id)
    }
    
    func hasAnswered(questionId: Int) -> Bool {
        return responseContext.keys.contains(questionId)
    }
    
    func getResponsesContext() -> [SurveyResponse] {
        let responseArray = Array(responseContext.values) as! [SurveyResponse]
        return responseArray
    }
    
    func firstNonAnsweredQuestion(on testPage: TestPage) -> Int {
        return testPage.questions.firstIndex(where: { responseContext[$0.id] == nil }) ?? testPage.questions.count
    }
    
    //MARK: - Setters
    
    func setResponse(_ newResponse: SurveyResponse) {
        let newResponseSet: Set = [newResponse]
        responseContext[newResponse.questionId] = newResponseSet
    }
    
    func toggleResponse(_ newResponse: SurveyResponse) {
        if responseContext.keys.contains(newResponse.questionId) {
            if responseContext[newResponse.questionId]!.contains(newResponse) {
                responseContext[newResponse.questionId]!.remove(newResponse)
            } else {
                responseContext[newResponse.questionId]!.insert(newResponse)
            }
        } else {
            setResponse(newResponse)
        }
    }
    
    func resetResponseContext() {
        responseContext = [:]
    }
    
}
