//
//  UIColorExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 05/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(data: Data) {
            let size = MemoryLayout<CGFloat>.size
            self.init(red:   data.subdata(in: size*0..<size*1).object(),
                      green: data.subdata(in: size*1..<size*2).object(),
                      blue:  data.subdata(in: size*2..<size*3).object(),
                      alpha: data.subdata(in: size*3..<size*4).object())
        }
        var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
            var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            return getRed(&red, green: &green, blue: &blue, alpha: &alpha) ?
            (red, green, blue, alpha) : nil
        }
        var data: Data? {
            guard let rgba = rgba else { return nil }
            return rgba.red.data + rgba.green.data + rgba.blue.data + rgba.alpha.data
        }
}
