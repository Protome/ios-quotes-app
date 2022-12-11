//
//  BookSelectionShelfListViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 27/06/2020.
//  Copyright © 2020 Protome. All rights reserved.
//

import Foundation
import UIKit

class BookSelectionShelfListViewController: UITableViewController {
    weak var bookDelegate: BookSelectionDelegate?
    let viewModel = BookSelectionShelfListViewModel()
    
    @IBOutlet weak var ErrorHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var bottomActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ErrorHeaderConstraint.constant = 0
        HeaderView.frame.size.height = 0
        
        refreshControl = UIRefreshControl(frame: tableView.frame)
        refreshControl?.addTarget(self, action: #selector(self.loadShelves(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        extendedLayoutIncludesOpaqueBars = true
        
        title = viewModel.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.gray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await self.loadShelves(self)            
        }
    }
    
    @objc func loadShelves(_ sender: Any) async -> Void {
        refreshControl?.beginRefreshing()
        
        await viewModel.loadBooksFromShelf(sender: self)
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
        self.bottomActivityIndicator?.stopAnimating()
        
        if viewModel.shelves.count == 0 {
            self.ErrorHeaderConstraint.constant = 87
            self.HeaderView.frame.size.height = 87
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BookSelectionViewController {
            destination.viewModel.shelf = viewModel.selectedShelf!
            destination.delegate = bookDelegate
        }
    }
}

extension BookSelectionShelfListViewController
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShelfCellView") as? ShelfCell else {
            return UITableViewCell()
        }
        
        let shelf = viewModel.shelves[indexPath.row]
        cell.setupCell(shelf: shelf, selected: false)
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shelves.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? ShelfCell else
        {
            return
        }
        viewModel.selectShelf(selected: indexPath.row)
        performSegue(withIdentifier: "ShowBooksFromShelf", sender: self)
    }
}
