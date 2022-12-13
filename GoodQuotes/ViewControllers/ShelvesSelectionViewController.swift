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
    var viewModel: ShelvesSelectionViewModel?
    
    var refreshControl : UIRefreshControl?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadShelves(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if popoverPresentationController?.presentationStyle == .popover {
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
        refreshControl?.beginRefreshing()
        Task {
            await loadShelves()
            
            tableview.reloadData()
            refreshControl?.endRefreshing()
            activityIndicator?.stopAnimating()
            view.layoutIfNeeded()
        }
    }
     
    func loadShelves() async -> Void {
        await viewModel?.loadShelves(sender: self)
    }
    
    @IBAction func selectShelf(_ sender: Any) {
        delegate?.shelfSelected(shelfName: viewModel?.currentShelf ?? "")
        navigationController?.popViewController(animated: true)
    }
}

extension ShelvesSelectionViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShelfCell") as? ShelfCell else {
            return UITableViewCell()
        }
        
        guard let shelf = viewModel?.shelves[indexPath.row] else { return cell }
        cell.setupCell(shelf: shelf, selected: shelf.name == viewModel?.currentShelf ?? "")
        if popoverPresentationController?.presentationStyle == .popover {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.shelves.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? ShelfCell else
        {
            return
        }
        viewModel?.selectShelf(selected: indexPath.row)
        deselectCells()
        
        if popoverPresentationController?.presentationStyle == .popover {
            DispatchQueue.main.async {
                self.delegate?.shelfSelected(shelfName: self.viewModel?.currentShelf ?? "")
            }
        }
    }
    
    func deselectCells()
    {
        for index in 0...tableview.numberOfRows(inSection: 0)
        {
            if let cell = tableview.cellForRow(at: IndexPath(row: index, section: 0)) as? ShelfCell, let currentShelf = viewModel?.currentShelf
            {
                cell.setSelected(selected: currentShelf == cell.TagLabel.text)
            }
        }
    }
}

protocol ShelvesSelectionDelegate: AnyObject
{
    func shelfSelected(shelfName: String)
}
