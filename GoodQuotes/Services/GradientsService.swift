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
                                       UIColor(named: "BlueGradientDark")!]
    
    static private let GreenGradient = [UIColor(named: "GreenGradient1")!,
                                        UIColor(named: "GreenGradient2")!]
    
    static private let YellowPeach = [UIColor(named: "LightYellow")!,
                                      UIColor(named: "Peach")!]
    
    static private let PeachPink = [UIColor(named: "Peach2")!,
                                    UIColor(named: "Pink")!]
    
    static private let PurPink = [UIColor(named: "DarkPurple")!,
                                  UIColor(named: "HotPink")!]
    
    static private var Custom: [UIColor] {
        get {
            let userDefaultService = UserDefaultsService()
            let colours = userDefaultService.loadColours()
            return colours ?? [UIColor(named: "Peach2")!, UIColor(named: "Pink")!]
        }
    }
    
    static let ColourMappings = ["GreenGradient": GreenGradient,
                                 "BlueGradient": BlueGradient,
                                 "YellowPeach": YellowPeach,
                                 "PeachPink": PeachPink,
                                 "PurPink": PurPink,
                                 "Custom": Custom]
}
