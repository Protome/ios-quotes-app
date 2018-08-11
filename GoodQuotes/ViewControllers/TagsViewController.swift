//
//  TagsViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class TagsViewController: UITableViewController {
    weak var delegate: TagsViewControllerDelegate?
    var selectedTag: Tags?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        let defaultsService = UserDefaultsService()
        let currentFilter = defaultsService.loadFilters()
        
        if let newFilter = currentFilter, newFilter.type == FilterType.Tag
        {
            selectedTag = Tags(rawValue: newFilter.filter)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCellView") as? TagCellView else {
            return UITableViewCell()
        }
        let tag = Tags.allValues[indexPath.row]
        cell.setupCell(tag: tag, selected: tag == selectedTag)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tags.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TagCellView, let tag = cell.customTag else
        {
            return
        }
        
        selectedTag = tag
        delegate?.tagSelected(tag: tag)
        
        deselectCells()
    }
    
    func deselectCells()
    {
        for index in 0...tableView.numberOfRows(inSection: 0)
        {
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TagCellView else {
                break
            }
            cell.setupCell(tag: cell.customTag!, selected: cell.customTag! == selectedTag)
        }
    }
}

protocol TagsViewControllerDelegate: class
{
    func tagSelected(tag: Tags)
}
