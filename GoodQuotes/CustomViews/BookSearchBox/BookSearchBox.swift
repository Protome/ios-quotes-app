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
    var searchResults: [Book] = [Book]()
    var parent : UIViewController?
    var resultsTableView : UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let parentVC = parent else { return }
        
        setupTableView()
        
        resultsTableView!.frame = CGRect(x: 0, y: parentVC.view.safeAreaInsets.top, width: parentVC.view.frame.width, height: CGFloat(parentVC.view.frame.height - parentVC.view.safeAreaInsets.top))
        parentVC.view.addSubview(resultsTableView!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resultsTableView?.removeFromSuperview()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        GoodreadsService.sharedInstance.searchForBooks(title: textField.text ?? "") {
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
        resultsTableView?.backgroundColor = UIColor.red.withAlphaComponent(0.4)
    }
}

extension BookSearchBox : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let temp = searchResults[indexPath.row]
        cell.textLabel?.text = temp.title
        return cell
    }
    

}
