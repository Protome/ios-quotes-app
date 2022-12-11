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
    let viewModel = BookSelectionViewModel()
    
    @IBOutlet weak var ErrorHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var bottomSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ErrorHeaderConstraint.constant = 0
        HeaderView.frame.size.height = 0
        
        title = viewModel.title
        refreshControl?.addTarget(self, action: #selector(self.loadBooks(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomSpinner.startAnimating()
        loadBooks(self)
    }
    
    @objc func loadBooks(_ sender: Any) {
        Task {
            await loadBooksFromShelf()
        }
    }
    
    func loadBooksFromShelf() async -> Void {
        refreshControl?.beginRefreshing()
        await viewModel.loadBooksFromShelf(sender: self)
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        self.ErrorHeaderConstraint.constant = viewModel.books.count == 0 ? 87 : 0
        self.HeaderView.frame.size.height = viewModel.books.count == 0 ? 87 : 0
        self.bottomSpinner.stopAnimating()
    }
}

extension BookSelectionViewController
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as? BookSearchResultCell else {
            return UITableViewCell()
        }
        
        cell.SetupCell(book: viewModel.books[indexPath.row])
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        
        if indexPath.row == (viewModel.pages?.lastItem ?? 1) - viewModel.buffer, viewModel.pages?.hasMoreToLoad ?? true {
            bottomSpinner.startAnimating()
            loadBooks(self)
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? BookSearchResultCell else
        {
            return
        }
        
        viewModel.selectBook(selected: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.bookSelected(book: viewModel.selectedBook!)
        dismiss(animated: true, completion: nil)
    }
}


protocol BookSelectionDelegate: AnyObject
{
    func bookSelected(book: Book)
}
