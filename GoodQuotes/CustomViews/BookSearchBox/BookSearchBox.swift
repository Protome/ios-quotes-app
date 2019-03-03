//
//  BookSearchBox.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 01/03/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BookSearchBox: UITextField, UITextFieldDelegate {
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    weak var bookSearchDelegate: BookSearchSelectionDelegate?
    
    var searchResults: [Book] = [Book]()
    var resultsTableView : UITableView?
    var backgroundView : UIView?
    var dismissKeyboardGestureRecogniser : UITapGestureRecognizer?
    let defaultsService = UserDefaultsService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
   
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        let currentType = defaultsService.loadCurrentFilterType()
        switch currentType {
        case .Search:
            text = defaultsService.loadSearch()
        case .Book:
            text = defaultsService.loadBook()?.title
        default:
            return
        }
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.contentMode = .center
            imageView.image = image
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let parentVC = bookSearchDelegate as? UIViewController else { return }
        
        setupDismissKeyboardView()
        setupTableView()
        
        let width = parentVC.view.frame.width * 0.85
        let inset = (parentVC.view.frame.width - width) / 2
        
        resultsTableView!.frame = CGRect(x: inset, y: parentVC.view.safeAreaInsets.top, width: width, height: CGFloat(parentVC.view.frame.height - parentVC.view.safeAreaInsets.top))
        parentVC.view.addSubview(resultsTableView!)
        
        searchByCurrentText()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissView()
    }
    
    func searchByCurrentText() {
        GoodreadsService.sharedInstance.searchForBooks(title: text ?? "") {
            books in
            self.searchResults = books
            self.resultsTableView?.reloadData()
        }
    }
    
    func setupTableView() {
        if resultsTableView != nil { return }
        
        resultsTableView = UITableView()
        resultsTableView?.delegate = self
        resultsTableView?.dataSource = self
        resultsTableView?.register(BookSearchResultCell.Nib, forCellReuseIdentifier: BookSearchResultCell.Identifier)
        resultsTableView?.register(TextOnlyResultCell.Nib, forCellReuseIdentifier: TextOnlyResultCell.Identifier)
        resultsTableView?.backgroundColor = UIColor.clear
        resultsTableView?.tableFooterView = UIView()
        resultsTableView?.showsVerticalScrollIndicator = false
        resultsTableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func setupDismissKeyboardView() {
        guard let parentVC = bookSearchDelegate as? UIViewController else { return }
        
        backgroundView = UIView(frame: parentVC.view.frame)
        dismissKeyboardGestureRecogniser = dismissKeyboardGestureRecogniser ?? UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        
        backgroundView!.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        backgroundView!.addGestureRecognizer(dismissKeyboardGestureRecogniser!)
        
        parentVC.view.addSubview(backgroundView!)
    }
    
    func dismissView() {
        guard let parentVC = bookSearchDelegate as? UIViewController else { return }
        
        parentVC.dismissKeyboard()
        self.resignFirstResponder()
        backgroundView?.removeGestureRecognizer(dismissKeyboardGestureRecogniser!)
        backgroundView?.removeFromSuperview()
        backgroundView = nil
        resultsTableView?.removeFromSuperview()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        SearchWithText()
        dismissView()
        return true
    }
    
    func ClearSearch() {
        defaultsService.wipeFilters()
        text = ""
    }
    
    func SearchWithText() {
        defaultsService.wipeFilters()
        
        if text!.count > 0 {
            defaultsService.storeSearchTerm(search: text!)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        searchByCurrentText()
    }
    
    @objc func backgroundTapped(sender: UITapGestureRecognizer) {
        dismissView()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            resultsTableView?.tableFooterView = UIView(frame: CGRect(x: 0,y: 0, width: 0, height: keyboardHeight))
        }
    }
}

extension BookSearchBox : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInFirstSection = text!.count > 0 ? 2 : 1
        return section == 0 ? numberOfRowsInFirstSection : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TextOnlyResultCell.Identifier) as? TextOnlyResultCell else { return UITableViewCell() }
            let cellText = indexPath.row == 0 ? "Clear Saved Search" : "All books & authors containing \"\(text!)\""
            cell.SetupCell(text: cellText)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookSearchResultCell.Identifier) as? BookSearchResultCell else { return UITableViewCell() }
        
        cell.SetupCell(book: searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                ClearSearch()
            }
            
            if indexPath.row == 1 {
                SearchWithText()
            }
        }
        else {
            let selectedBook = searchResults[indexPath.row]
            text = "\(selectedBook.title) \(selectedBook.author.name)"
        
            defaultsService.storeBook(book: selectedBook)
        }
        dismissView()
        
        bookSearchDelegate?.newSearchTermSelected()
    }
}

protocol BookSearchSelectionDelegate: class where Self: UIViewController
{
    func newSearchTermSelected()
}
