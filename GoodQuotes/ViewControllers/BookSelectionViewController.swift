//
//  BookSelectionViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 27/06/2020.
//  Copyright © 2020 Protome. All rights reserved.
//

import Foundation
import UIKit

class BookSelectionViewController: UITableViewController {
    weak var delegate: ShelvesSelectionDelegate?
    
    @IBOutlet weak var ErrorHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var HeaderView: UIView!
    
    var books = [Book]()
    var shelf: Shelf?
    
    override func viewDidLoad() {
        ErrorHeaderConstraint.constant = 0
        HeaderView.frame.size.height = 0
        
        title = shelf?.name
        
        refreshControl = UIRefreshControl(frame: tableView.frame)
        refreshControl?.addTarget(self, action: #selector(self.loadBooks(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadBooks(self)
    }
    
    @objc func loadBooks(_ sender: Any) {
        let goodreadsService = GoodreadsService()
        guard let shelf = shelf else {
            return
        }
        
        refreshControl?.beginRefreshing()
        
        goodreadsService.getBooksFromShelf(sender: self, shelf: shelf, page: 1, completion: { books in
            self.books = books
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            self.ErrorHeaderConstraint.constant = books.count == 0 ? 87 : 0
            self.HeaderView.frame.size.height = books.count == 0 ? 87 : 0
        })
    }
    
    @IBAction func selectBook(_ sender: Any) {
        //        delegate?.shelfSelected(shelfName: currentShelf)
        navigationController?.popViewController(animated: true)
    }
}

extension BookSelectionViewController
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as? BookSearchResultCell else {
            return UITableViewCell()
        }
        
        cell.SetupCell(book: books[indexPath.row])
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? TagCellView else
        {
            return
        }
    }
}
