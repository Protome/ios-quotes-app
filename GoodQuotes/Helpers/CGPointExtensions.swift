//
//  CGPointExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 19/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }
    
}
