//
//  FiltersViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class FiltersViewController: UIViewController {
    let tagTitle = "Tag"
    let authorTitle = "Author"
    let bookTitle = "Book Title"
    let tagSegueIdentifier = "ShowTagFilters"
    let authorSegueIdentifier = "AddAuthorFilter"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var currentSelection: (filter:String, type: FilterType) = (filter: "", type: FilterType.None)
    var changesMade = false
    let defaultsService = UserDefaultsService()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        currentSelection = defaultsService.loadFilters() ?? (filter: "", type: FilterType.None)
    }
    
    @IBAction func ApplyFilters(_ sender: UIButton) {
        if currentSelection.type != .None, changesMade
        {
            defaultsService.storeFilter(filter: currentSelection.filter, type: currentSelection.type)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ResetToDefaults(_ sender: Any) {
        defaultsService.wipeFilters()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TagsViewController {
            destination.delegate = self
        }
        if let destination = segue.destination as? AuthorEntryViewController {
            destination.delegate = self
        }
    }
    
    func updateCells()
    {
        for index in 0...tableView.numberOfRows(inSection: 0)
        {
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FilterCell else
            {
                return
            }
            
            cell.TitleLabel.text = titleForRow(index)
        }
    }
    
    func titleForRow(_ index: Int) -> String
    {
        switch index {
        case 0:
            return currentSelection.type == FilterType.Tag ? "\(tagTitle): \(currentSelection.filter)" : tagTitle
        case 1:
            return currentSelection.type == FilterType.Author ? "\(authorTitle): \(currentSelection.filter)" : authorTitle
        case 2:
            return currentSelection.type == FilterType.Title ?  "\(bookTitle): \(currentSelection.filter)" : bookTitle
        default:
            return ""
        }
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as? FilterCell else {
            return UITableViewCell()
        }
        
        cell.TitleLabel.text = titleForRow(indexPath.row)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? FilterCell else
        {
            return
        }
        
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: tagSegueIdentifier, sender: self)
            break
            
        case 1:
            performSegue(withIdentifier: authorSegueIdentifier, sender: self)
            break
        default: break
        }
    }
}

extension FiltersViewController: TagsViewControllerDelegate, AuthorEntryViewControllerDelegate
{
    func tagSelected(tag: Tags) {
        currentSelection = (filter: tag.rawValue, type: .Tag)
        changesMade = true
        updateCells()
    }
    
    func authorSelected(author: String)
    {
        currentSelection = (filter: author, type: .Author)
        changesMade = true
        updateCells()
    }
}
