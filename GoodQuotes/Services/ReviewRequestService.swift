//
//  ReviewRequestService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 01/09/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import StoreKit

class ReviewRequestService {
    let runIncrementerSetting = "numberOfRuns"
    let minimumRunCount = 4
    
    func incrementAppRuns() {
        let usD = UserDefaults()
        let runs = getRunCounts() + 1
        usD.setValuesForKeys([runIncrementerSetting: runs])
        usD.synchronize()
    }
    
    func resetAppRuns() {
        let usD = UserDefaults()
        usD.setValuesForKeys([runIncrementerSetting: 0])
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
    
    func showReview() {
        let runs = getRunCounts()
        
        if (runs > minimumRunCount) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                resetAppRuns()
            }
        }
    }
}
