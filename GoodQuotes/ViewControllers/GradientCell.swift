//
//  GradientCell.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 03/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit
import Pastel

class GradientCell: UICollectionViewCell
{
    func setupCell(gradientName: String)
    {
        guard let colours = GradientsService.ColourMappings[gradientName] else
        {
            return
        }
        
        let pastelView = PastelView(frame: bounds)
        
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        pastelView.animationDuration = 1.4
        
        pastelView.setColors(colours)
        insertSubview(pastelView, at: 0)
        
        let delay = Double.random(in: 0 ... 0.6)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            pastelView.startAnimation()
        }
    }
}
