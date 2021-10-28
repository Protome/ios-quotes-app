//
//  GradientView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 04/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var startingColour: UIColor? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var midColour: UIColor? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var endColour: UIColor? {
        didSet {
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateView()
    }
    
    init(frame: CGRect, startingColour: UIColor, midColour: UIColor?, endColour: UIColor)
    {
        super.init(frame: frame)
        self.startingColour = startingColour
        self.midColour = midColour
        self.endColour = endColour
    }
    
    override func didMoveToSuperview() {
        guard let superview = superview else {
            return
        }
        
        superview.addConstraints([
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: superview, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: 0)
            ])
        
        layoutIfNeeded()
        
        updateView()
    }
    
    func updateView() {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        if midColour == nil || midColour == UIColor.clear {
            gradient.colors = [startingColour?.cgColor ?? UIColor.white, endColour?.cgColor ?? UIColor.black]
        }
        else {
            gradient.colors = [startingColour?.cgColor ?? UIColor.white, midColour?.cgColor ?? UIColor.gray, endColour?.cgColor ?? UIColor.black]
        }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }
}
