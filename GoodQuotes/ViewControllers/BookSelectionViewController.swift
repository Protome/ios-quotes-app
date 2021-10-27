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
    weak var delegate: BookSelectionDelegate?
    
    @IBOutlet weak var ErrorHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var bottomSpinner: UIActivityIndicatorView!
    
    let buffer = 15
    var books = [Book]()
    var shelf: Shelf?
    var pages: Pages?
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ErrorHeaderConstraint.constant = 0
        HeaderView.frame.size.height = 0
        
        title = shelf?.name
        refreshControl?.addTarget(self, action: #selector(self.loadBooks(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomSpinner.startAnimating()
        loadBooks(self)
    }
    
    @objc func loadBooks(_ sender: Any) {
        let goodreadsService = GoodreadsService()
        guard let shelf = shelf, !isLoading else {
            return
        }
        isLoading = true
        refreshControl?.beginRefreshing()
        
        goodreadsService.getBooksFromShelf(sender: self, shelf: shelf, page: pages?.nextPage ?? 1, completion: { books, pages in
            self.pages = pages
            if(pages.currentPage == 1) {
                self.books = books
                self.tableView.reloadData()
            }
            else {
                if books.count == 0 { return }
                
                let previousResultCount = self.books.count
                self.books.append(contentsOf: books)
                var indexesToUpdate = [IndexPath]()
                for index in previousResultCount...(self.books.count - 1) {
                    indexesToUpdate.append(IndexPath(row: index, section: 0))
                }
                
                UIView.setAnimationsEnabled(false)
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: indexesToUpdate, with: UITableView.RowAnimation.none)
                self.tableView?.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
            
            
            self.refreshControl?.endRefreshing()
            self.ErrorHeaderConstraint.constant = books.count == 0 ? 87 : 0
            self.HeaderView.frame.size.height = books.count == 0 ? 87 : 0
            self.isLoading = false
            self.bottomSpinner.stopAnimating()
        })
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
        
        if indexPath.row == (pages?.lastItem ?? 1) - buffer, pages?.hasMoreToLoad ?? true {
            bottomSpinner.startAnimating()
            loadBooks(self)
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
        guard let _ = tableView.cellForRow(at: indexPath) as? BookSearchResultCell else
        {
            return
        }
        
        let selectedBook = books[indexPath.row]
        let defaultsService = UserDefaultsService()
        defaultsService.storeBook(book: selectedBook)
        
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.bookSelected(book: selectedBook)
        dismiss(animated: true, completion: nil)
    }
}


protocol BookSelectionDelegate: AnyObject
{
    func bookSelected(book: Book)
}
