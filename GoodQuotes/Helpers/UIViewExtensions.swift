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
    
//    func toImage(withinFrame: CGRect) -> UIImage? {
//        let renderer = UIGraphicsImageRenderer(bounds: withinFrame)
//        return renderer.image { _ in
//            drawHierarchy(in: bounds, afterScreenUpdates: true)
//        }
//    }
    
    func toImage(withinFrame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
//            drawHierarchy(in: withinFrame, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            let croppedImage = UIImage(cgImage: image!.cgImage!.cropping(to: withinFrame)!)
            return croppedImage
        }
        return nil
    }
}
