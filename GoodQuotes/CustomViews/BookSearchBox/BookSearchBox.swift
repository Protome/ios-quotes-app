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
    weak var bookSearchDelegate: BookSearchSelectionDelegate?
    
    var searchResults: [Book] = [Book]()
    var parent : UIViewController?
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
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let parentVC = parent else { return }
        
        setupDismissKeyboardView()
        setupTableView()
        
        let width = parentVC.view.frame.width * 0.85
        let inset = (parentVC.view.frame.width - width) / 2
        
        resultsTableView!.frame = CGRect(x: inset, y: parentVC.view.safeAreaInsets.top, width: width, height: CGFloat(parentVC.view.frame.height - parentVC.view.safeAreaInsets.top))
        parentVC.view.addSubview(resultsTableView!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resultsTableView?.removeFromSuperview()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        GoodreadsService.sharedInstance.searchForBooks(title: textField.text ?? "") {
            books in
                self.searchResults = books
            
            self.resultsTableView?.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.fade)
        }
    }
    
    func setupTableView() {
        if resultsTableView != nil { return }
        
        resultsTableView = UITableView()
        resultsTableView?.delegate = self
        resultsTableView?.dataSource = self
        resultsTableView?.register(BookSearchResultCell.Nib, forCellReuseIdentifier: BookSearchResultCell.Identifier)
        resultsTableView?.backgroundColor = UIColor.clear
        resultsTableView?.tableFooterView = UIView()
        resultsTableView?.showsVerticalScrollIndicator = false
        resultsTableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func setupDismissKeyboardView() {
        backgroundView = UIView(frame: parent!.view.frame)
        dismissKeyboardGestureRecogniser = dismissKeyboardGestureRecogniser ?? UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        
        backgroundView!.backgroundColor = UIColor.clear
        backgroundView!.addGestureRecognizer(dismissKeyboardGestureRecogniser!)
        
        parent!.view.addSubview(backgroundView!)
    }
    
    func dismissView() {
        parent?.dismissKeyboard()
        self.resignFirstResponder()
        backgroundView?.removeGestureRecognizer(dismissKeyboardGestureRecogniser!)
        backgroundView?.removeFromSuperview()
        backgroundView = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSearching()
        return true
    }
    
    func handleSearching() {
        if text!.isEmpty {
            defaultsService.removeStoredBook()
        }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookSearchResultCell.Identifier) as? BookSearchResultCell else { return UITableViewCell() }
        
        cell.SetupCell(book: searchResults[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBook = searchResults[indexPath.row]
        text = selectedBook.title
        
        defaultsService.storeBook(book: selectedBook)
        dismissView()
        
        bookSearchDelegate?.newSearchTermSelected()
    }
}

protocol BookSearchSelectionDelegate: class
{
    func newSearchTermSelected()
}
