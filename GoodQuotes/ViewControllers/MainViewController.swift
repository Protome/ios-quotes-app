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
import ChromaColorPicker

class MainViewController: UIViewController {
    
    @IBOutlet weak var QuoteLabel: UILabel!
    @IBOutlet weak var BookLabel: UILabel!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    
    @IBOutlet weak var GoodreadsButton: BlurButtonView!
    @IBOutlet weak var ShareButton: BlurButtonView!
    @IBOutlet weak var RefreshButton: BlurButtonView!
    
    @IBOutlet weak var BookBackgroundView: UIVisualEffectView!
    @IBOutlet weak var BookCoverImageview: UIImageView!
    @IBOutlet weak var BookViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var RatingLabel: UILabel!
    
    @IBOutlet weak var BookSearchField: BookSearchBox!
    @IBOutlet weak var PickerTestView: UIView!
    @IBOutlet weak var PickerTestView2: UIView!
    
    let averageRatingText = "Average Rating:"
    let quoteService = QuoteService()
    let reviewService = ReviewRequestService()
    var pastelView:PastelView?
    var currentBook:Book?
    var restartAnimation = true
    var returningFromAuth = false
    var openModal: UIViewController?
    var maxDistanceTop: CGFloat = 0
    var colourPickerTopRight: ChromaColorPicker?
    var colourPickerBottomLeft: ChromaColorPicker?
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupButtons()
        setupNavBar()
        let test = UIColor(named: "BlueGradientDark")
        let test2 = UIColor(named: "BlueGradientLight")
        colourPickerTopRight?.adjustToColor(test ?? UIColor.gray)
        colourPickerBottomLeft?.adjustToColor(test2 ?? UIColor.purple)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        guard let bookId = currentBook?.id else {
            return
        }
        
        UIApplication.shared.open(URL(string: "https://www.goodreads.com/book/show/\(bookId)")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func setupNavBar() {
        let hasBeenSetUp = self.navigationController?.navigationBar.subviews.contains(where: { view in
            return view is UIVisualEffectView
        }) ?? false
        
        if hasBeenSetUp { return }
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        let barHeight = self.view.safeAreaInsets.top
        let offsetY = self.navigationController!.navigationBar.bounds.origin.y + (self.navigationController!.navigationBar.bounds.height - barHeight)
        visualEffectView.frame = CGRect(origin: CGPoint(x: self.navigationController!.navigationBar.bounds.origin.x, y: offsetY),
                                        size: CGSize(width: self.navigationController!.navigationBar.bounds.width, height: barHeight ))
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.addSubview(visualEffectView)
        self.navigationController?.navigationBar.sendSubviewToBack(visualEffectView)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupButtons() {
        ShareButton.buttonAction = shareQuote
        GoodreadsButton.buttonAction = addBookToShelf
        GoodreadsButton.forceTouchAction = GoodreadsService.sharedInstance.isLoggedIn == .LoggedIn ? selectShelfAction : nil
        RefreshButton.buttonAction = loadRandomQuote
    }
    
    func shareQuote() {
        if let image = view.toImage(withinFrame: backgroundView.frame) {
            let vc = UIActivityViewController(activityItems: [image, "#Quotey"], applicationActivities: [])
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
        
        pastelView.setColors(GradientsService.ColourMappings["GreenGradient"] ?? [UIColor.red])
        view.insertSubview(pastelView, at: 0)
    }
    
    private func styleView()
    {
        backgroundView.layer.cornerRadius = 6
        backgroundView.clipsToBounds = true
        
        BookBackgroundView.layer.cornerRadius = 6
        BookBackgroundView.clipsToBounds = true
        
        maxDistanceTop = BookViewTopConstraint.constant
        
        BookCoverImageview.layer.cornerRadius = 2
        
        BookViewTopConstraint.constant = -maxDistanceTop
        BookBackgroundView.alpha = 0
        
        colourPickerTopRight = ChromaColorPicker(frame: PickerTestView.bounds)
        colourPickerTopRight!.delegate = self //ChromaColorPickerDelegate
        colourPickerTopRight!.padding = 5
        colourPickerTopRight!.stroke = 3
        colourPickerTopRight!.hexLabel.textColor = UIColor.white
        
        colourPickerBottomLeft = ChromaColorPicker(frame: PickerTestView2.bounds)
        colourPickerBottomLeft!.delegate = self //ChromaColorPickerDelegate
        colourPickerBottomLeft!.padding = 5
        colourPickerBottomLeft!.stroke = 3
        colourPickerBottomLeft!.hexLabel.textColor = UIColor.white

        PickerTestView.addSubview(colourPickerTopRight!)
        PickerTestView2.addSubview(colourPickerBottomLeft!)
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
                GoodreadsService.sharedInstance.searchForBook(title: quote.publication, author: quote.author) { book in
                    self.currentBook = book
                    self.setupCurrentBookButton(book)
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

extension MainViewController: ChromaColorPickerDelegate
{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        pastelView?.removeFromSuperview()
        pastelView = nil
        pastelView = PastelView(frame: view.bounds)

        guard let pastelView = pastelView else {
            return
        }
        
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        pastelView.animationDuration = 1.5
        
        pastelView.setColors([colourPickerTopRight?.currentColor ?? UIColor(named: "BlueGradientLight")!,
                              colourPickerBottomLeft?.currentColor ?? UIColor(named: "BlueGradientDark")!])
        view.insertSubview(pastelView, at: 0)
        pastelView.startAnimation()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
