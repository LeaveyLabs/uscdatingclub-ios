//
//  TestQuestion.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/04.
//

import Foundation

protocol TestQuestion {
    var id: Int { get }
    var title: String { get }
}

struct SpectrumTestQuestion: TestQuestion {
    let id: Int
    let title: String
    //spectrum, 1-7
}

struct SelectionTestQuestion: TestQuestion {
    let id: Int
    let title: String
    let options: [String]
}

typealias TestPage = Int

var TestPages: Int {
    TestPageTitles.count
}
let TestPageTitles: [String] = [
    "part 1: personality",
    "part 2: preferences",
    "part 3: values",
    "part 4: lifestyle",
]

let TestQuestions: [TestPage: [TestQuestion]] = [
    0: [SpectrumTestQuestion(id: 0,
                     title: "I would consider myself clean & organized."),
        SpectrumTestQuestion(id: 1,
                     title: "I enjoy being the center of attention."),
        SpectrumTestQuestion(id: 2,
                     title: "I’m more of a stay-at-home and Netflix kind of person."),
        SpectrumTestQuestion(id: 3,
                     title: "I’m more inclined to follow my heart than my head."),
        SpectrumTestQuestion(id: 4,
                    title: "I’m usually the one to take charge in a situation."),
//        SelectionTestQuestion(id: 5,
//                              title: "languages spoken",
//                              options: ["arabic", "english", "korean", ])
    ],
    1: [SpectrumTestQuestion(id: 6,
                     title: "I would rather go to a music festival than a museum."),
        SpectrumTestQuestion(id: 7,
                     title: "At the start of a relationship, I would rather text than meet up in person."),
        SpectrumTestQuestion(id: 8,
                     title: "I’d rather binge my For You feed than read a book."),
        SpectrumTestQuestion(id: 9,
                     title: "I prefer spontaneous adventures to vacations with set plans."),
        SpectrumTestQuestion(id: 10,
                    title: "I would think twice about an awesome experience if it’s out of my budget."),
        SelectionTestQuestion(id: 11,
                              title: "love language",
                              options: ["gift giving", "quality time", "acts of service", "words of affirmation", "physical touch"])],
    2: [SpectrumTestQuestion(id: 12,
                     title: "Family is an important part of my life."),
        SpectrumTestQuestion(id: 13,
                     title: "I am minimalistisc and enjoy having fewer posessions."),
        SpectrumTestQuestion(id: 14,
                     title: "I am more traditional in my values and beliefs."),
        SpectrumTestQuestion(id: 15,
                     title: "I’m a foodie and like to appreciate good food at nice restaurants."),
        SpectrumTestQuestion(id: 16,
                    title: "I would like to have pets down the road."),
        SelectionTestQuestion(id: 17,
                              title: "political leaning",
                              options: ["not political", "liberal", "moderate", "conservative", "other"]),
        SelectionTestQuestion(id: 18,
                              title: "religious beliefs",
                              options: ["agnostic", "atheist", "buddhist", "catholic", "christian", "hindu", "jewish", "muslim", "sikh", "spiritual", "other"])],
    3: [SpectrumTestQuestion(id: 19,
                     title: "I would like to live abroad for a long period of time."),
        SpectrumTestQuestion(id: 20,
                     title: "I’m more of a morning person."),
        SpectrumTestQuestion(id: 21,
                     title: "I consistently share memes with my friends."),
        SpectrumTestQuestion(id: 22,
                    title: "I’m always open to trying new experiences."),
        SelectionTestQuestion(id: 23,
                              title: "dietary preference",
                              options: ["none", "vegan", "vegetarian", "flexitarian", "pescatarian", "carnivore", "gluten-free", "dairy-free", "raw food", "halal", "other"]),
        SelectionTestQuestion(id: 24,
                              title: "drug consumption",
                              options: ["none", "drinking", "smoking", "marijuana", "other"])]
]
