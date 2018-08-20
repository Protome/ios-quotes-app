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
        touchExited = false
        touchMoved(touch: touches.first)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        touchMoved(touch: touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEnded(touch: touches.first)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchEnded(touch: touches.first)
    }
    
    private func touchMoved(touch: UITouch?) {
        guard let touch = touch, !touchExited else { return }
        
        let cancelDistance: CGFloat = minWidth / 2 + 20
        guard touch.location(in: self).distance(to: CGPoint(x: bounds.midX, y: bounds.midY)) < cancelDistance else {
            touchExited = true
            forceState = .reset
            animateToRest()
            return
        }
        
        let force = touch.force / touch.maximumPossibleForce
        let scale = 1 + (maxWidth / minWidth - 1) * force
        
        transform = CGAffineTransform(scaleX: scale, y: scale)
        if !isOn { backgroundColor = UIColor(white: 0.2 - force * 0.2, alpha: 1) }
        
        switch forceState {
        case .reset:
            if force >= activationForce, forceTouchAction != nil {
                forceState = .activated
                activationFeedbackGenerator.impactOccurred()
            }
        case .activated:
            if force <= confirmationForce, forceTouchAction != nil {
                forceState = .confirmed
                activate()
            }
        case .confirmed:
            if force <= resetForce {
                forceState = .reset
            }
        }
    }
    
    private func touchEnded(touch: UITouch?) {
        guard !touchExited else { return }
        if frame.width  <= minWidth * 1.06, forceState != .activated  {
            buttonAction?()
        }
        
        if forceState == .activated, forceTouchAction != nil {
            activate()
        }
        
        forceState = .reset
        animateToRest()
    }
    
    func activate() {
        isOn = !isOn
        backgroundColor = isOn ? onColor : offColor
        confirmationFeedbackGenerator.impactOccurred()
        forceTouchAction?(isOn)
    }
    
    private func animateToRest() {
        let timingParameters = UISpringTimingParameters(damping: 0.4, response: 0.2)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = self.isOn ? self.onColor : self.offColor
        }
        animator.isInterruptible = true
        animator.startAnimation()
    }
}

extension UISpringTimingParameters {
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}
