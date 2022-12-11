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
    let segmentHeader = UISegmentedControl(items: ["Title", "Author", "Either"])
    let refreshControl = UIRefreshControl()
    
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
        
        resultsTableView?.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
        Task { await searchByCurrentText() }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissView()
    }
    
    func searchByCurrentText() async -> Void {
        let title = segmentHeader.selectedSegmentIndex == 0 ? text : nil
        let author = segmentHeader.selectedSegmentIndex == 1 ? text : nil
        let query = segmentHeader.selectedSegmentIndex == 2 ? text : nil
        
        resultsTableView?.setContentOffset( CGPoint(x: 0, y: -refreshControl.frame.height) , animated: false)
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        let response = await OpenLibraryService.sharedInstance.searchForBooks(title: title, author: author, query: query)
        if response.1 { return }
        
        self.searchResults = response.0
        self.resultsTableView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func setupTableView() {
        if resultsTableView != nil { return }
        resultsTableView = UITableView()
        
        segmentHeader.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        
        resultsTableView?.tableHeaderView = segmentHeader
        resultsTableView?.refreshControl = refreshControl
        resultsTableView?.delegate = self
        resultsTableView?.dataSource = self
        resultsTableView?.register(BookSearchResultCell.Nib, forCellReuseIdentifier: BookSearchResultCell.Identifier)
        resultsTableView?.register(TextOnlyResultCell.Nib, forCellReuseIdentifier: TextOnlyResultCell.Identifier)
        resultsTableView?.backgroundColor = UIColor.clear
        resultsTableView?.showsVerticalScrollIndicator = false
        resultsTableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        segmentHeader.selectedSegmentIndex = 0
    }
    
    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        Reload()
    }
    
    @objc func refreshPulled() {
        Reload()
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
    
    func Reload() {
        resultsTableView?.setContentOffset( CGPoint(x: 0, y: 0) , animated: true)
        Task { await searchByCurrentText() }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        Reload()
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
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let parentVC = bookSearchDelegate as? UIViewController, let resultsTableView = resultsTableView else { return }
            let maxHeight = CGFloat(parentVC.view.frame.height - parentVC.view.safeAreaInsets.top)
            let height = min(resultsTableView.contentSize.height + refreshControl.frame.height, maxHeight)
            resultsTableView.frame = CGRect(x: resultsTableView.frame.origin.x, y: resultsTableView.frame.origin.y, width: resultsTableView.frame.width, height: height)
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
            text = "\(selectedBook.title)"
            
            defaultsService.storeBook(book: selectedBook)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        dismissView()
        
        bookSearchDelegate?.newSearchTermSelected()
    }
}

protocol BookSearchSelectionDelegate: AnyObject
{
    func newSearchTermSelected()
}
