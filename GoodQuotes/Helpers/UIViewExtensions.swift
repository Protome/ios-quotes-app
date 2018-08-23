//
//  UIViewExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 20/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func toImage(withinFrame: CGRect) -> UIImage? {
        let convertedFrame = convert(withinFrame, to: self)
        UIGraphicsBeginImageContextWithOptions(withinFrame.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
                context.concatenate(CGAffineTransform(translationX: -withinFrame.origin.x, y: -withinFrame.origin.y))
                layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}
