//
//  BlurButtonView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import UIKit

@IBDesignable class BlurButtonView: UIView {
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var ButtonImage: UIButton!
    @IBOutlet weak var BlurBackground: UIVisualEffectView!
    
    var buttonAction: (() -> ())?
    
    @IBInspectable var image: UIImage? {
        get {
            return ButtonImage.imageView?.image
        }
        set(image) {
            ButtonImage.setImage(image, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
        layer.cornerRadius = bounds.width/2
    }
    
    func commonInit() {
        let bundle = Bundle(for: BlurButtonView.self)
        bundle.loadNibNamed("BlurButtonView", owner: self, options: nil)
        addSubview(ContentView)
        ContentView.frame = bounds
        ContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.cornerRadius = bounds.width/2
        clipsToBounds = true
        self.setNeedsDisplay()
    }
    
    @IBAction func onTouchDown(_ sender: Any) {
        backgroundColor = UIColor.lightGray
    }
    
    @IBAction func onTouchUpInside(_ sender: Any) {
        backgroundColor = UIColor.clear
        buttonAction?()
    }
    
}
