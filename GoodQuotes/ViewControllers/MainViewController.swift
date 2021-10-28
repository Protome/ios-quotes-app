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
    @IBOutlet weak var QuoteContainerView: UIView!
    
    @IBOutlet weak var GoodreadsButton: BlurButtonView!
    @IBOutlet weak var ShareButton: BlurButtonView!
    @IBOutlet weak var RefreshButton: BlurButtonView!
    
    @IBOutlet weak var BookBackgroundView: UIVisualEffectView!
    @IBOutlet weak var BookCoverImageview: UIImageView!
    @IBOutlet weak var BookViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var RatingLabel: UILabel!
    
    @IBOutlet weak var DividerLine: UIView!
    @IBOutlet weak var BookSearchField: BookSearchBox!
    
    @IBOutlet weak var BookSelectButton: UIBarButtonItem!
    
    let averageRatingText = "Average Rating:"
    let quoteService = QuoteService()
    let reviewService = ReviewRequestService()
    var pastelView:PastelView?
    var currentBook:Book?
    var restartAnimation = true
    var returningFromAuth = false
    var openModal: UIViewController?
    var maxDistanceTop: CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        restartAnimation = !returningFromAuth
        addGradient()
        
        if(!returningFromAuth) {
            loadRandomQuote()
        }
        else {
            pastelView?.startAnimation()
            pastelView?.pauseAnimation()
        }
        
        BookSelectButton.isEnabled = GoodreadsService.sharedInstance.isLoggedIn == LoginState.LoggedIn
        BookSelectButton.image = GoodreadsService.sharedInstance.isLoggedIn == LoginState.LoggedIn ? UIImage(systemName: "book.circle") : UIImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupButtonsFromNotification),
                                               name: .loginStateChanged,
                                               object: nil)
        
        BookSearchField.bookSearchDelegate = self
        
        GoodreadsService.sharedInstance.isLoggedIn = AuthStorageService.readAuthToken().isEmpty ? .LoggedOut : .LoggedIn
        styleView()
        setupButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if navigationController?.navigationBar != nil {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let destination = nav.topViewController as? BookSelectionShelfListViewController {
            destination.bookDelegate = self
        }
        
        if let nav = segue.destination as? UINavigationController, let destination = nav.topViewController as? FiltersViewController {
            destination.delegate = self
        }
    }
    
    @objc func setupButtonsFromNotification(_ notification: Notification) {
        setupButtons()
    }
    
    @IBAction func legacyButtonTouchUpInside(_ sender: Any) {
        guard let button = sender as? BlurButtonView else {
            return
        }
        
        button.backgroundColor = UIColor.clear
        
        if button == GoodreadsButton {
            addBookToShelf()
        }
        
        if button == ShareButton {
            shareQuote()
        }
        
        if button == RefreshButton {
            loadRandomQuote()
        }
    }
    
    @IBAction func legacyButtonTouchUpOutside(_ sender: Any) {
        guard let button = sender as? BlurButtonView else {
            return
        }
        
        button.backgroundColor = UIColor.clear
    }
    
    @IBAction func legacyButtonTouchDown(_ sender: Any) {
        guard let button = sender as? BlurButtonView else {
            return
        }
        
        button.backgroundColor = UIColor.lightGray
    }
    
    @IBAction func ViewBookOnGoodreads(_ sender: Any) {
        var bookUrl = "https://www.goodreads.com/book/show/"
        if let book = currentBook, book.isbn != "" {
            bookUrl = bookUrl + "isbn/\(book.isbn)"
        }
        else if let book = currentBook, book.id != "" {
            bookUrl = bookUrl + book.id
        }
        
        guard let url = URL(string: bookUrl) else {
            return
        }
        
        OpenUrlInSafari(url:url)
    }
    
    @IBAction func SelectBookFromAccount(_ sender: Any) {
        performSegue(withIdentifier: "ShowBookList", sender: self)
    }
   
    func setupButtons() {
        ShareButton.buttonAction = shareQuote
        GoodreadsButton.buttonAction = addBookToShelf
        GoodreadsButton.forceTouchAction = GoodreadsService.sharedInstance.isLoggedIn == .LoggedIn ? selectShelfAction : nil
        RefreshButton.buttonAction = loadRandomQuote
    }
    
    @IBOutlet weak var testImage: UIImageView!
    func shareQuote() {
        guard let background = pastelView?.snapshot() else  {return}
        let dummyBackgroundImage = UIImageView(image: background)
        
        QuoteContainerView.insertSubview(dummyBackgroundImage, at: 0)
        
        let image = QuoteContainerView.snapshot()
        
        dummyBackgroundImage.removeFromSuperview()
        
        let vc = UIActivityViewController(activityItems: [image, "#Quotey"], applicationActivities: [])
        present(vc, animated: true)
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
        GoodreadsService.sharedInstance.addBookToShelf(sender: self, bookId: book.id) {
            self.pastelView?.pauseAnimation()
            self.returningFromAuth = false
        }
    }
    
    func selectShelfAction(_ isActive: Bool) {
        guard isActive else {
            return
        }
        
        if GoodreadsService.sharedInstance.isLoggedIn == .LoggedOut{
            GoodreadsService.sharedInstance.loginToGoodreadsAccount(sender: self) {
                self.selectShelfAction(isActive)
            }
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
        shelvesVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: GoodreadsButton.frame.width, height: GoodreadsButton.frame.height)
        shelvesVC.popoverPresentationController?.delegate = self
        shelvesVC.view.backgroundColor = UIColor.clear
        shelvesVC.tableview.alwaysBounceVertical = false
        shelvesVC.preferredContentSize = CGSize(width: shelvesVC.view.frame.width * 0.65, height: shelvesVC.view.frame.height * 0.4)
        openModal = shelvesVC
        
        self.present(shelvesVC, animated: true) {
        }
        
        GoodreadsButton.activate()
    }
    
    private func addGradient()
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
        
        let defaultsService = UserDefaultsService()
        let colourType = defaultsService.loadBackgroundType()
        
        if colourType == "Custom", let colours = defaultsService.loadColours() {
            pastelView.setColors(colours)
        }
        else {
            pastelView.setColors(GradientsService.ColourMappings[colourType] ?? [UIColor.red])
        }
        view.insertSubview(pastelView, at: 0)
    }
    
    private func styleView()
    {
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        BookBackgroundView.layer.cornerRadius = 10
        BookBackgroundView.clipsToBounds = true
        
        maxDistanceTop = BookViewTopConstraint.constant
        
        BookCoverImageview.layer.cornerRadius = 4
        
        BookViewTopConstraint.constant = -maxDistanceTop
        BookBackgroundView.alpha = 0
        
        DividerLine.layer.cornerRadius = 4
        view.layoutIfNeeded()
    }
    
    private func loadRandomQuote()
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
            self.QuoteLabel.text = "\(quote.quote)"
            self.AuthorLabel.text = quote.author
            self.BookLabel.text = quote.publication
            
            UIView.animate(withDuration: 1.2,
                           delay: 0, usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.0,
                           options: .beginFromCurrentState,
                           animations: {
                            self.view.layoutIfNeeded()
                           })
            
            self.RatingLabel.text = self.averageRatingText
            self.updateBookImage(bookCover: nil)
            
            if quote.publication.isEmpty {
                self.currentBook = nil
                self.hideBookDetails()
            }
            else {
                OpenLibraryService.sharedInstance.searchForBook(title: quote.publication, author: quote.author) { book in
                    
                    guard let bookResult = book else {
                        self.currentBook = nil
                        self.hideBookDetails()
                        return
                    }
                    
                    self.currentBook = bookResult
                    self.setupCurrentBookButton(bookResult)
                    self.showBookDetails()
                }
            }
            
            let deadlineTime = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.reviewService.showReview()
            }
            
            self.pastelView?.pauseAnimation()
        }
    }
    
    private func setupCurrentBookButton(_ book: Book) {
        Alamofire.request(book.imageUrl).responseImage { imageReponse in
            if let image = imageReponse.result.value {
                self.updateBookImage(bookCover: image)
            }
        }
        
        RatingLabel.text = "\(averageRatingText) \(book.averageRating)/5"
    }
    
    private func updateBookImage(bookCover: UIImage?) {
        UIView.transition(with: self.BookCoverImageview,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.BookCoverImageview.image = bookCover },
                          completion: nil)
    }
    
    private func showBookDetails() {
        BookViewTopConstraint.constant = maxDistanceTop
        
        UIView.animate(withDuration: 1.4,
                       delay: 0, usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.BookBackgroundView.alpha = 1
                        self.view.layoutIfNeeded()
                       }, completion: nil)
    }
    
    private func hideBookDetails() {
        BookViewTopConstraint.constant = -maxDistanceTop
        
        UIView.animate(withDuration: 1.4,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.BookBackgroundView.alpha = 0
                        self.view.layoutIfNeeded()
                       }, completion: nil)
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

extension MainViewController: BookSearchSelectionDelegate {
    func newSearchTermSelected() {
        loadRandomQuote()
    }
}

extension MainViewController: BookSelectionDelegate {
    func bookSelected(book: Book) {
        BookSearchField.text = "\(book.title) \(book.author.name)"
        loadRandomQuote()
    }
}

extension MainViewController: SettingsDelegate {
    func ScreenClosing() {
        addGradient()
        pastelView?.startAnimation()
        pastelView?.pauseAnimation()
    }
}
