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
    
    @IBOutlet weak var ErrorHeaderConstraint: NSLayoutConstraint!
    @IBOutlet weak var HeaderView: UIView!
    var shelves = [Shelf]()
    var selectedShelf: Shelf?

    override func viewDidLoad() {
        ErrorHeaderConstraint.constant = 0
        HeaderView.frame.size.height = 0
        
        refreshControl = UIRefreshControl(frame: tableView.frame)
        refreshControl?.addTarget(self, action: #selector(self.loadShelves(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        loadShelves(self)
    }
    
    @objc func loadShelves(_ sender: Any) {
        let goodreadsService = GoodreadsService()
        refreshControl?.beginRefreshing()
        
        goodreadsService.loadShelves(sender: self) { shelves in
            self.shelves = shelves
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            
            if shelves.count == 0 {
                self.ErrorHeaderConstraint.constant = 87
                self.HeaderView.frame.size.height = 87
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BookSelectionViewController {
            destination.shelf = selectedShelf!
            destination.delegate = bookDelegate
        }
    }
    
    @IBAction func closeModal(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectShelf(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension BookSelectionShelfListViewController
{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShelfCellView") as? TagCellView else {
            return UITableViewCell()
        }
        
        let shelfName = shelves[indexPath.row].name
        cell.TagLabel.text = shelfName
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shelves.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? TagCellView else
        {
            return
        }
        selectedShelf = shelves[indexPath.row]
        performSegue(withIdentifier: "ShowBooksFromShelf", sender: self)
    }
}
