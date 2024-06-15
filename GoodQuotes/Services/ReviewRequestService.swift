//
//  ReviewRequestService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 01/09/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import StoreKit

class ReviewRequestService: ReviewRequestServiceProtocol {
    let runIncrementerSetting = "numberOfRuns"
    let runDateString = "lastDateRun"
    let minimumRunCount = 4
    let monthsBetweenRequests = 6
    
    func incrementAppRuns() {
        let usD = UserDefaults()
        let runs = getRunCounts() + 1
        usD.setValuesForKeys([runIncrementerSetting: runs])
        usD.synchronize()
    }
    
    func resetAppRuns() {
        let usD = UserDefaults()
        usD.setValuesForKeys([runIncrementerSetting: 0, runDateString: Date()])
        usD.synchronize()
    }
    
    func getRunCounts () -> Int {
        let usD = UserDefaults()
        let savedRuns = usD.value(forKey: runIncrementerSetting)
        
        var runs = 0
        if (savedRuns != nil) {
            
            runs = savedRuns as! Int
        }
        
        return runs
    }
    
    func getLastRequestDate() -> Date {
        let usD = UserDefaults()
        let savedDate = usD.value(forKey: runDateString)
        var date = Date.distantPast
        
        if(savedDate != nil) {
            date = savedDate as! Date
        }
        
        return date
    }
    
    func timeSinceLastRequest(lastRequest: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: lastRequest, to: Date())
        let months = components.month ?? 0
        return months > 6
    }
    
    func showReview() {
        let lastRequestDate = getLastRequestDate()
        let runs = getRunCounts()
        
        if (runs > minimumRunCount && timeSinceLastRequest(lastRequest: lastRequestDate)) {
                SKStoreReviewController.requestReview()
                resetAppRuns()
        }
    }
}
