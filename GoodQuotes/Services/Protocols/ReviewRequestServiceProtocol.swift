//
//  ReviewRequestServiceProtocol.swift
//  GoodQuotes
//
//  Created by Kieran on 06/12/2022.
//  Copyright © 2022 Protome. All rights reserved.
//

import Foundation

protocol ReviewRequestServiceProtocol {
    func incrementAppRuns()
    func resetAppRuns()
    func getRunCounts () -> Int
    func getLastRequestDate() -> Date
    func timeSinceLastRequest(lastRequest: Date) -> Bool
    func showReview()
}
