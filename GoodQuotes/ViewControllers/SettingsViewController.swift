//
//  FiltersViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

protocol SettingsDelegate: AnyObject
{
    func ScreenClosing()
}

class SettingsViewController: UIViewController {
    weak var delegate: SettingsDelegate?
    var viewModel: SettingsViewModel?
    
    @IBOutlet weak var tableView: UITableView!
    
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
        viewModel?.setCurrentShelf()
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
    
    func signInOutGoodreads() {
        guard let viewModel = viewModel else { return }
        
        if(viewModel.loggedIntoGoodreads) {
            let alert = UIAlertController(title: "Are you sure?", message: "You'll need to log in again to add books to your shelves (the rest of the app will still work)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.viewModel?.logoutOfGoodreads()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        else {
            Task {
                await viewModel.loginToGoodreads(sender: self)
                self.tableView.reloadData()
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") as? FilterCell else {
            return UITableViewCell()
        }
        
        cell.TitleLabel.text = viewModel?.titleForRow(indexPath: indexPath)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.sections.keys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sections[section]!.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = viewModel?.sections[indexPath.section]?[indexPath.row] else
        {
            return
        }
        
        if let segue = viewModel?.segueForSection[section] {
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
        return viewModel?.sectionTitles[section]
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

extension SettingsViewController: ShelvesSelectionDelegate
{
    func shelfSelected(shelfName: String) {
        viewModel?.shelfSelected(shelfName: shelfName)
        tableView.reloadData()
    }
}
