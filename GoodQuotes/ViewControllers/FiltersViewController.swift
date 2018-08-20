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
    case CustomTag = "CustomTag"
    case GoodreadsShelf = "Goodreads Shelf"
    case About = "About"
    case SignInOutGoodreads = "SignInOutGoodreads"
}

class FiltersViewController: UIViewController {
    let tagSegueIdentifier = "ShowTagFilters"
    let customTagSegueIdentifier = "AddCustomTagFilter"
    let shelvesSegueIdentifier = "ShowShelves"
    let aboutSegueIdentifier = "ShowAcknowledgements"
    
    let goodreadsTitles = (signIn: "Sign In to Goodreads", signOut: "Sign Out of Goodreads")
    
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
                          1 : "Settings",
                          2 : "Goodreads",
                          3 : "Other"]
        
        sections =  [ 0 : [.Tag, .CustomTag],
                      1 : [.GoodreadsShelf],
                      2 : [.SignInOutGoodreads],
                      3 : [.About]]
        
        segueForSection = [ .Tag : tagSegueIdentifier,
                            .CustomTag : customTagSegueIdentifier,
                            .GoodreadsShelf : shelvesSegueIdentifier,
                            .About : aboutSegueIdentifier]
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sectionTitles = [ 0 : "Filters",
                          1 : "Settings",
                          2 : "Goodreads",
                          3 : "Other"]
        
        sections =  [ 0 : [.Tag, .CustomTag],
                      1 : [.GoodreadsShelf],
                      2 : [.SignInOutGoodreads],
                      3 : [.About]]
        
        segueForSection = [ .Tag : tagSegueIdentifier,
                            .CustomTag : customTagSegueIdentifier,
                            .GoodreadsShelf : shelvesSegueIdentifier,
                            .About : aboutSegueIdentifier]
        
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        guard let navController = navigationController else {
            return
        }
        
        navController.navigationBar.tintColor = UIColor.darkGray
    }
    
    override func viewDidLoad() {
        currentSelection = defaultsService.loadFilters() ?? (filter: "", type: FilterType.None)
        currentShelf = defaultsService.loadDefaultShelf() ?? ""
        
        tableView.reloadData()
    }
    
    @IBAction func ApplyFilters(_ sender: UIButton) {
        if currentSelection.type != .None, changesMade {
            defaultsService.storeFilter(filter: currentSelection.filter, type: currentSelection.type)
        }
        if(changesMade) {
            defaultsService.storeDefaultShelf(shelfName: currentShelf)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ResetToDefaults(_ sender: Any) {
        defaultsService.wipeFilters()
        currentSelection = (filter: "", type: FilterType.None)
        currentShelf = "to-read"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TagsViewController {
            destination.delegate = self
        }
        if let destination = segue.destination as? CustomTagEntryViewController {
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
        case .CustomTag:
            return currentSelection.type == FilterType.CustomTag ? "\(item.rawValue): \(currentSelection.filter)" : item.rawValue
        case .GoodreadsShelf:
            return currentShelf.isEmpty ? item.rawValue : "\(item.rawValue): \(currentShelf)"
        case .SignInOutGoodreads:
            return GoodreadsService.sharedInstance.isLoggedIn == .LoggedIn ? goodreadsTitles.signOut : goodreadsTitles.signIn
        default:
            return item.rawValue
        }
    }
    
    func signInOutGoodreads() {
        let goodreadsService = GoodreadsService.sharedInstance
        if(GoodreadsService.sharedInstance.isLoggedIn == .LoggedIn) {
            goodreadsService.logoutOfGoodreadsAccount()
            self.tableView.reloadData()
        }
        else {
            goodreadsService.loginToGoodreadsAccount(sender: self) {
                self.tableView.reloadData()
            }
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
        guard let section = sections[indexPath.section]?[indexPath.row] else
        {
            return
        }
        
        if let segue = segueForSection[section] {
            performSegue(withIdentifier: segue, sender: self)
            return
        }
        
        if section == .SignInOutGoodreads {
            signInOutGoodreads()
        }
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

extension FiltersViewController: TagsViewControllerDelegate, CustomTagEntryViewControllerDelegate, ShelvesSelectionDelegate
{
    func tagSelected(tag: Tags) {
        currentSelection = (filter: tag.rawValue, type: .Tag)
        changesMade = true
        updateFilterCells()
    }
    
    func customTagSelected(tag: String) {
        currentSelection = (filter: tag, type: .CustomTag)
        changesMade = true
        updateFilterCells()
    }
    
    func shelfSelected(shelfName: String) {
        currentShelf = shelfName
        changesMade = true
        tableView.reloadData()
    }
}
