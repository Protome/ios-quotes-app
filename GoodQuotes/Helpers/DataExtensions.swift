//
//  DataExtension.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 28/10/2021.
//  Copyright © 2021 Protome. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    func object<T>() -> T { withUnsafeBytes{$0.load(as: T.self)} }
    var color: UIColor { .init(data: self) }
}
