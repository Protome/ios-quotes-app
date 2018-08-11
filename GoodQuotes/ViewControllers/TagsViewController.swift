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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCellView") as? TagCellView else {
            return UITableViewCell()
        }
        
        cell.setupCell(tag: Tags.allValues[indexPath.row], selected: false)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tags.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView(tableView, didSelectRowAt: indexPath)
        guard let cell = tableView.cellForRow(at: indexPath) as? TagCellView, let tag = cell.customTag else
        {
            return
        }
        
        delegate?.tagSelected(tag: tag)
    }
}

protocol TagsViewControllerDelegate: class
{
    func tagSelected(tag: Tags)
}
