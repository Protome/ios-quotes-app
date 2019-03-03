//
//  TagsViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class TagsViewController: UIViewController {
    weak var delegate: TagsViewControllerDelegate?
    var selectedTag: Tags?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        let defaultsService = UserDefaultsService()
//        let currentFilter = defaultsService.loadFilters()
//        
//        if let newFilter = currentFilter, newFilter.type == FilterType.Tag
//        {
//            selectedTag = Tags(rawValue: newFilter.filter)
//        }
    }
    
    @IBAction func SelectTag(_ sender: Any) {
        if(selectedTag != nil)
        {
            delegate?.tagSelected(tag: selectedTag!)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension TagsViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCellView") as? TagCellView else {
            return UITableViewCell()
        }
        let tag = Tags.allValues[indexPath.row]
        cell.setupCell(tag: tag, selected: tag == selectedTag)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Tags.allValues.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TagCellView, let tag = cell.customTag else
        {
            return
        }
        
        selectedTag = tag
        
        deselectCells()
    }
    
    func deselectCells()
    {
        for index in 0...tableView.numberOfRows(inSection: 0)
        {
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TagCellView
            {
                cell.setupCell(tag: cell.customTag!, selected: cell.customTag! == selectedTag)
            }
        }
    }
}

protocol TagsViewControllerDelegate: class
{
    func tagSelected(tag: Tags)
}
