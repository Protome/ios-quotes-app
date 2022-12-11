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
    case GoodreadsShelf = "Goodreads Shelf"
    case About = "About"
    case SignInOutGoodreads = "SignInOutGoodreads"
    case VisitGoodreads = "Visit Goodreads"
    case Feedback = "Feedback"
    case ChangeBackground = "Change Background Colour"
}

protocol SettingsDelegate: AnyObject
{
    func ScreenClosing()
}

class FiltersViewController: UIViewController {
    weak var delegate: SettingsDelegate?
    
    let goodreadsTitles = (signIn: "Sign In to Goodreads", signOut: "Sign Out of Goodreads")
    let defaultShelf = "to-read"
    
    let sectionTitles = [0 : "Settings",
                          1 : "Goodreads",
                          2 : "Other"]
    
    let sections: [Int : [Settings]] = [0 : [.GoodreadsShelf, .ChangeBackground],
                     1 : [.SignInOutGoodreads, .VisitGoodreads],
                     2 : [.About, .Feedback]]
    
    let segueForSection: [Settings : String] = [.GoodreadsShelf : "ShowShelves",
                                                .About : "ShowAcknowledgements",
                                                .Feedback : "ShowFeedback",
                                                .ChangeBackground : "ChangeBackground" ]

    @IBOutlet weak var tableView: UITableView!
    
    var currentShelf = ""
    var changesMade = false
    let defaultsService = UserDefaultsService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        guard let navController = navigationController else {
            return
        }
        
        navController.navigationBar.tintColor = UIColor.gray
    }
    
    override func viewDidLoad() {
        currentShelf = defaultsService.loadDefaultShelf() ?? defaultShelf
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShelvesSelectionViewController {
            destination.delegate = self
        }
    }
    
    override func closeModal(_ sender: Any) {
        delegate?.ScreenClosing()
        
        dismiss(animated: true, completion: nil)
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
            let alert = UIAlertController(title: "Are you sure?", message: "You'll need to log in again to add books to your shelves (the rest of the app will still work)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                goodreadsService.logoutOfGoodreadsAccount()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else {
            Task {
                await goodreadsService.loginToGoodreads(sender: self)
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
        
        if section == .VisitGoodreads, let url = URL(string: "https://www.goodreads.com") {
            UIApplication.shared.open(url)
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

extension FiltersViewController: ShelvesSelectionDelegate
{
    func shelfSelected(shelfName: String) {
        currentShelf = shelfName
        defaultsService.storeDefaultShelf(shelfName: currentShelf)
        tableView.reloadData()
    }
}
