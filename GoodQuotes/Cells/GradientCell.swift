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
    @IBOutlet weak var GradientBackgroundContainer: UIView!
    
    var pastelView: PastelView?
    var gradientView: GradientView?
    
    override var isSelected: Bool
        {
        didSet {
            if isSelected {
                createAnimatedGradient()
                gradientView?.removeFromSuperview()
            }
            else {
                createGradientView()
                pastelView?.removeFromSuperview()
            }
            
            GradientBackgroundContainer.layer.borderWidth = isSelected ? 1 : 0
        }
    }
    
    var gradientName: String?
    
    func setupCell(gradientName: String)
    {
        self.gradientName = gradientName
        GradientBackgroundContainer.layer.cornerRadius = 10
        GradientBackgroundContainer.layer.borderColor = UIColor.black.cgColor
        
        createGradientView()
        
//        if gradientName == "Custom"
//        {
//            let colourPicker = ChromaColorPicker(frame: GradientBackgroundContainer.bounds)
//            colourPicker.isUserInteractionEnabled = false
//            GradientBackgroundContainer.addSubview(colourPicker)
//        }
    }
    
    func createGradientView()
    {
        guard let colourName = gradientName, let colours = GradientsService.ColourMappings[colourName] else
        {
            return
        }
        
        gradientView = GradientView(frame: GradientBackgroundContainer.bounds, startingColour: colours[0], midColour: nil, endColour: colours[1])
        GradientBackgroundContainer.insertSubview(gradientView!, at: 0)
    }
    
    func createAnimatedGradient()
    {
        guard let colourName = gradientName, let colours = GradientsService.ColourMappings[colourName] else
        {
            return
        }
        
        pastelView = PastelView(frame: GradientBackgroundContainer.bounds)
        
        pastelView!.startPastelPoint = .bottomLeft
        pastelView!.endPastelPoint = .topRight
        pastelView!.animationDuration = 1.4
        
        pastelView!.setColors(colours)
        GradientBackgroundContainer.insertSubview(pastelView!, at: 0)
        pastelView!.startAnimation()
    }
}
