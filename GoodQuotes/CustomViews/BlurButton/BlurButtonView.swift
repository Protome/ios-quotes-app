//
//  BlurButtonView.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import UIKit

@IBDesignable class BlurButtonView: UIControl {
    @IBOutlet var ContentView: UIView!
    @IBOutlet weak var ButtonImage: UIButton!
    @IBOutlet weak var BlurBackground: UIVisualEffectView!
    
    private enum ForceState {
        
        /// The button is ready to be activiated. Default state.
        case reset
        
        /// The button has been pressed with enough force.
        case activated
        
        /// The button has recently switched on/off.
        case confirmed
    }
    
    private var isOn = false
    
    private var forceState: ForceState = .reset
    private var touchExited = false
    
    private let activationFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let confirmationFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var minWidth: CGFloat = 42
    private var maxWidth: CGFloat = 42
    
    private let offColor = UIColor.clear
    private let onColor = UIColor(white: 0.95, alpha: 1)
    
    private let activationForce: CGFloat = 0.5
    private let confirmationForce: CGFloat = 0.49
    private let resetForce: CGFloat = 0.4
    
    var buttonAction: (() -> ())?
    var forceTouchAction: ((Bool) -> ())?
    
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
        minWidth = bounds.width
        maxWidth = bounds.width * 1.6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
}

extension BlurButtonView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
            sendActions(for: .touchDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sendActions(for: .touchUpInside)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
            sendActions(for: .touchUpOutside)
    }

    func activate() {
        isOn = !isOn
        backgroundColor = isOn ? onColor : offColor
        confirmationFeedbackGenerator.impactOccurred()
    }
}

extension UISpringTimingParameters {
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}
