//
//  ViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import UIKit
import Pastel

class MainViewController: UIViewController {
    
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var BookLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var ReRollButton: UIButton!
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    @IBOutlet weak var RefreshButtonBackground: UIVisualEffectView!
    
    let quoteService = QuoteService()
    var pastelView:PastelView?
    var firstLoad = true
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradient()
        styleView()
        loadRandomQuote()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ReRollButtonPressed(_ sender: Any) {
        ReRollButton.backgroundColor = UIColor.clear
        loadRandomQuote()
    }
    
    @IBAction func ReRollButtonPressedDown(_ sender: Any) {
        ReRollButton.backgroundColor = UIColor.lightGray
    }
    
    internal func addGradient()
    {
        pastelView = PastelView(frame: view.bounds)
        
        guard let pastelView = pastelView else {
            return
        }
        
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        pastelView.animationDuration = 1.5
        pastelView.setColors([UIColor(red:0.09, green:0.31, blue:0.41, alpha:1.0),
                              UIColor(red:0.40, green:0.79, blue:0.60, alpha:1.0)])

        view.insertSubview(pastelView, at: 0)
    }
    
    internal func styleView()
    {
        backgroundView.layer.cornerRadius = 6
        backgroundView.clipsToBounds = true
        
        RefreshButtonBackground.layer.cornerRadius = RefreshButtonBackground.bounds.width/2
        RefreshButtonBackground.clipsToBounds = true
        
    }
    
    internal func loadRandomQuote()
    {
        if(firstLoad)
        {
            pastelView?.startAnimation()
            firstLoad = false
        }
        else {
            pastelView?.resumeAnimation()
        }
        quoteService.getRandomQuote { quote in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                self.QuoteLabel.text = quote.quote
                self.AuthorLabel.text = quote.author
                self.BookLabel.text = quote.publication
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
                self.pastelView?.pauseAnimation()
            }
        }
    }
}

