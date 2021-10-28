//
//  UserDefaultExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 28/10/2021.
//  Copyright © 2021 Protome. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    func set(_ color: UIColor?, forKey defaultName: String) {
        guard let data = color?.data else {
            removeObject(forKey: defaultName)
            return
        }
        set(data, forKey: defaultName)
    }
    func color(forKey defaultName: String) -> UIColor? {
        data(forKey: defaultName)?.color
    }
}
