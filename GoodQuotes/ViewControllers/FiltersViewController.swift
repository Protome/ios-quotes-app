//
//  FiltersViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

enum Settings: String {
    case Tag = "Tag"
    case Author = "Author"
    case GoodreadsShelf = "Goodreads Shelf"
}

class FiltersViewController: UIViewController {
    let tagSegueIdentifier = "ShowTagFilters"
    let authorSegueIdentifier = "AddAuthorFilter"
    let shelvesSegueIdentifier = "ShowShelves"
    
    let sectionTitles: [Int : String]
    let sections: [Int : [Settings]]
    let segueForSection: [Settings : String]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var currentSelection: (filter:String, type: FilterType) = (filter: "", type: FilterType.None)
    var currentShelf = ""
    var changesMade = false
    let defaultsService = UserDefaultsService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        sectionTitles = [ 0 : "Filters",
                          1 : "Settings"]
        
        sections =  [ 0 : [.Tag, .Author],
                      1 : [.GoodreadsShelf]]
        
        segueForSection = [ .Tag : tagSegueIdentifier,
                            .Author : authorSegueIdentifier,
                            .GoodreadsShelf : shelvesSegueIdentifier]
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sectionTitles = [ 0 : "Filters",
                          1 : "Settings"]
        
        sections =  [ 0 : [.Tag, .Author],
                      1 : [.GoodreadsShelf]]
        
        segueForSection = [ .Tag : tagSegueIdentifier,
                            .Author : authorSegueIdentifier,
                            .GoodreadsShelf : shelvesSegueIdentifier]
        
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        currentSelection = defaultsService.loadFilters() ?? (filter: "", type: FilterType.None)
        currentShelf = defaultsService.loadDefaultShelf() ?? ""
    }
    
    @IBAction func ApplyFilters(_ sender: UIButton) {
        if currentSelection.type != .None, changesMade
        {
            defaultsService.storeFilter(filter: currentSelection.filter, type: currentSelection.type)
            defaultsService.storeDefaultShelf(shelfName: currentShelf)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ResetToDefaults(_ sender: Any) {
        defaultsService.wipeFilters()
        currentSelection = (filter: "", type: FilterType.None)
        updateFilterCells()
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
        if let destination = segue.destination as? ShelvesSelectionViewController {
            destination.delegate = self
        }
    }
    
    func updateFilterCells()
    {
        for index in 0...tableView.numberOfRows(inSection: 0)
        {
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FilterCell else
            {
                return
            }
            
            cell.TitleLabel.text = titleForRow(sections[0]![index])
        }
    }
    
    func titleForRow(_ item: Settings) -> String
    {
        switch item {
        case .Tag:
            return currentSelection.type == FilterType.Tag ? "\(item.rawValue): \(currentSelection.filter)" : item.rawValue
        case .Author:
            return currentSelection.type == FilterType.Author ? "\(item.rawValue): \(currentSelection.filter)" : item.rawValue
        case .GoodreadsShelf:
            return currentShelf.isEmpty ? item.rawValue : "\(item.rawValue): \(currentShelf)"
        }
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as? FilterCell else {
            return UITableViewCell()
        }
        
        cell.TitleLabel.text = titleForRow(sections[indexPath.section]![indexPath.row])
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section]!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = sections[indexPath.section]?[indexPath.row], let segue = segueForSection[section] else
        {
            return
        }
        
        performSegue(withIdentifier: segue, sender: self)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
}

extension FiltersViewController: TagsViewControllerDelegate, AuthorEntryViewControllerDelegate, ShelvesSelectionDelegate
{
    func tagSelected(tag: Tags) {
        currentSelection = (filter: tag.rawValue, type: .Tag)
        changesMade = true
        updateFilterCells()
    }
    
    func authorSelected(author: String)
    {
        currentSelection = (filter: author, type: .Author)
        changesMade = true
        updateFilterCells()
    }
    
    func shelfSelected(shelfName: String) {
        currentShelf = shelfName
        changesMade = true
        tableView.reloadData()
    }
}
