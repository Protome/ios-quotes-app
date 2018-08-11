//
//  Tags.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation

enum Tags: String {
    case None
    case Funny
    case Love
    case Life
    case Inspirational
    case Philosophy
    case Wisdom
    case Quotes
    case Happiness
    case Romance
    case Hope
    case Death
    case Poetry
    case Faith
    case Writing
    case Religion
    case Success
    case Knowledge
    case Relationships
    case Motivational
    case Education
    case Time
    case Science
    case Spirituality
    
    static let allValues = [None, Funny, Love, Life, Inspirational, Philosophy, Wisdom, Quotes, Happiness, Romance, Hope, Death, Poetry, Faith, Writing, Religion, Success, Knowledge, Relationships, Motivational, Education, Time, Science, Spirituality]
    
    static var selectedTag = None
}

//extension Tags: CaseIterable {}
