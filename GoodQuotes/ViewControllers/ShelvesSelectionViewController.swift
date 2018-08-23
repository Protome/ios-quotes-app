//
//  ShelvesSelectionViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 17/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class ShelvesSelectionViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var selectHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: ShelvesSelectionDelegate?
    
    var refreshControl : UIRefreshControl?
    var currentShelf = ""
    var shelves = [Shelf]()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        let defaultsService = UserDefaultsService()
        let savedShelf = defaultsService.loadDefaultShelf()
        
        if let shelf = savedShelf {
            currentShelf = shelf
        }
       
        loadShelves(self)
        
        if popoverPresentationController?.presentationStyle == .popover {
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            selectHeightConstraint.constant = 0
            view.layoutIfNeeded()
        }
        else {
            refreshControl = UIRefreshControl(frame: tableview.frame)
            refreshControl?.addTarget(self, action: #selector(self.loadShelves(_:)), for: .valueChanged)
            tableview?.refreshControl = refreshControl
        }
    }
    
    @objc func loadShelves(_ sender: Any) {
        let goodreadsService = GoodreadsService()
        goodreadsService.loadShelves(sender: self) { shelves in
            self.activityIndicator.stopAnimating()
            self.shelves = shelves
            self.tableview.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func selectShelf(_ sender: Any) {
        delegate?.shelfSelected(shelfName: currentShelf)
        navigationController?.popViewController(animated: true)
    }
}

extension ShelvesSelectionViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCellView") as? TagCellView else {
            return UITableViewCell()
        }
    
        let shelfName = shelves[indexPath.row].name
        cell.TagLabel.text = shelfName
        cell.setSelected(selected: shelfName == currentShelf)
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shelves.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? TagCellView else
        {
            return
        }
        
        currentShelf = shelves[indexPath.row].name
        deselectCells()
        
        if popoverPresentationController?.presentationStyle == .popover {
           DispatchQueue.main.async {
            self.delegate?.shelfSelected(shelfName: self.currentShelf)
            }
        }
    }
    
    func deselectCells()
    {
        for index in 0...tableview.numberOfRows(inSection: 0)
        {
            if let cell = tableview.cellForRow(at: IndexPath(row: index, section: 0)) as? TagCellView
            {
                cell.setSelected(selected: currentShelf == cell.TagLabel.text)
            }
        }
    }
}

protocol ShelvesSelectionDelegate: class
{
    func shelfSelected(shelfName: String)
}
