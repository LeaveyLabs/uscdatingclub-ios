//
//  TestQuestion.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/04.
//

import Foundation

struct TestQuestion {
    let id: Int
    let title: String
    let highPhrase: String
    let lowPhrase: String
}

typealias TestPage = Int

let TestPages: Int = 2
let TestPageTitles: [String] = [
    "part 1: personality",
    "part 2: idk",
]

let TestQuestions: [TestPage: [TestQuestion]] = [
    0: [TestQuestion(id: 0,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 1,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 2,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 3,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 4,
                    title: "openness to new experiences",
                    highPhrase: "very open",
                    lowPhrase: "not at all"),],
    1: [TestQuestion(id: 5,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 6,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 7,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 8,
                     title: "openness to new experiences",
                     highPhrase: "very open",
                     lowPhrase: "not at all"),
        TestQuestion(id: 9,
                    title: "openness to new experiences",
                    highPhrase: "very open",
                    lowPhrase: "not at all"),],
]
