//
//  GradientsService.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 03/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

class GradientsService {
    static private let BlueGradient = [UIColor(named: "BlueGradientLight")!,
                        UIColor(named: "BlueGradientMid")!,
                        UIColor(named: "BlueGradientDark")!]
    
    static private let GreenGradient = [UIColor(named: "GreenGradient1")!,
                         UIColor(named: "GreenGradient2")!,
                         UIColor(named: "GreenGradient1")!,
                         UIColor(named: "GreenGradient2")!]
    
    static let ColourMappings = ["GreenGradient": GreenGradient,
                                 "BlueGradient": BlueGradient]
}
