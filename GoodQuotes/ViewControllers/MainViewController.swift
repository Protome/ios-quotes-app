//
//  ViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 09/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import UIKit
import Pastel
import Alamofire
import AlamofireImage

class MainViewController: UIViewController {
    
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var BookLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    
    @IBOutlet weak var GoodreadsButton: BlurButtonView!
    @IBOutlet weak var ShareButton: BlurButtonView!
    @IBOutlet weak var RefreshButton: BlurButtonView!
    
    let quoteService = QuoteService()
    let goodReadService = GoodreadsService()
    var pastelView:PastelView?
    var currentBook:Book?
    var restartAnimation = true
    var returningFromAuth = false
    var openModal: UIViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        restartAnimation = true
        addGradient()
        if(!returningFromAuth) {
            loadRandomQuote()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleView()
        setupButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupButtons() {
        ShareButton.buttonAction = shareQuote
        GoodreadsButton.buttonAction = addBookToShelf
        GoodreadsButton.forceTouchAction = selectShelfAction
        RefreshButton.buttonAction = loadRandomQuote
    }
    
    func shareQuote() {
        if let quote = QuoteLabel.text {
            let vc = UIActivityViewController(activityItems: [quote], applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    func addBookToShelf() {
        guard let book = currentBook else {
            return
        }
        
        if(restartAnimation)
        {
            pastelView?.startAnimation()
            restartAnimation = false
        }
        else {
            pastelView?.resumeAnimation()
        }
        returningFromAuth = true
        goodReadService.addBookToShelf(sender: self, bookId: book.id) {
            self.pastelView?.pauseAnimation()
            self.returningFromAuth = false
        }
    }
    
    func selectShelfAction(_ isActive: Bool) {
        guard isActive else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let optionsVC = storyboard.instantiateViewController(withIdentifier: "ShelvesSelectionViewController") as? ShelvesSelectionViewController
        
        guard let shelvesVC = optionsVC else {
            GoodreadsButton.activate()
            return
        }
        shelvesVC.delegate = self
        shelvesVC.modalPresentationStyle = .popover
        shelvesVC.popoverPresentationController?.sourceView = GoodreadsButton
        shelvesVC.popoverPresentationController?.delegate = self
        shelvesVC.view.backgroundColor = UIColor.clear
        shelvesVC.tableview.alwaysBounceVertical = false
        openModal = shelvesVC
        
        self.present(shelvesVC, animated: true) {
        }
        
        GoodreadsButton.activate()
    }

    internal func addGradient()
    {
        pastelView?.removeFromSuperview()
        pastelView = nil
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
    }
    
    internal func loadRandomQuote()
    {
        if(restartAnimation)
        {
            pastelView?.startAnimation()
            restartAnimation = false
        }
        else {
            pastelView?.resumeAnimation()
        }
        quoteService.getRandomQuote { quote in
            self.QuoteLabel.text = quote.quote
            self.AuthorLabel.text = quote.author
            self.BookLabel.text = quote.publication
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
            
            if !quote.publication.isEmpty {
                self.goodReadService.searchForBook(title: quote.publication) { book in
                    self.currentBook = book
                    print(book)
                }
            }
            else {
                self.currentBook = nil
            }
            self.pastelView?.pauseAnimation()
        }
    }
}

extension MainViewController: ShelvesSelectionDelegate, UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func shelfSelected(shelfName: String) {
        openModal?.dismiss(animated: true, completion: nil)
    
        let defaultsService = UserDefaultsService()
        defaultsService.storeDefaultShelf(shelfName: shelfName)
    }
}

