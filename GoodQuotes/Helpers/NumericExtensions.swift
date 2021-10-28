//
//  NumericExtension.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 28/10/2021.
//  Copyright © 2021 Protome. All rights reserved.
//

import Foundation

extension Numeric {
    var data: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}
