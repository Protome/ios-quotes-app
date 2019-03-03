//
//  UIImageViewExtensions.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 02/03/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension UIImageView {
     func setImageFromUrl(_ url: String) {
        guard !url.isEmpty else { return }
        
        Alamofire.request(url).responseImage { imageResponse in
            if let image = imageResponse.result.value {
                self.updateImageWithDefaultTransition(image: image)
            }
        }
    }
    
    func updateImageWithDefaultTransition(image: UIImage?) {
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.image = image },
                          completion: nil)
    }
}
