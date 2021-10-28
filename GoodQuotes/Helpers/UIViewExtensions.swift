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
    func toImage(withinFrame: CGRect) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: withinFrame)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
    
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }
    
//    func takeScreenshot(withinFrame: CGRect, with scale: CGFloat? = nil) -> Data? {
//        guard withinFrame.width > 0, withinFrame.height > 0 else {
//            return nil
//        }
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = 1
//
//        let renderer = UIGraphicsImageRenderer(size: withinFrame.size, format: format)
//        let image = renderer.pngData { rendererContext in
//            self.layer.render(in: rendererContext.cgContext)
//        }
//        return image
//    }
    
    func snapshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
                    drawHierarchy(in: bounds, afterScreenUpdates: true)
                }
    }
}
