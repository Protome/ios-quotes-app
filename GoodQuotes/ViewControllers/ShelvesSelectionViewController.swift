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
    
    weak var delegate: ShelvesSelectionDelegate?
    
    var currentShelf = ""
    var shelves = [Shelf]()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        let defaultsService = UserDefaultsService()
        let savedShelf = defaultsService.loadDefaultShelf()
        let goodreadsService = GoodreadsService()
        
        if let shelf = savedShelf {
            currentShelf = shelf
        }
        
        goodreadsService.loadShelves(sender: self) { shelves in
            self.shelves = shelves
            self.tableview.reloadData()
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
