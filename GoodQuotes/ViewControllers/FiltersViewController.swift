//
//  FiltersViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 11/08/2018.
//  Copyright © 2018 Protome. All rights reserved.
//

import Foundation
import UIKit

class FiltersViewController: UITableViewController, TagsViewControllerDelegate {
    func tagSelected(tag: Tags) {
        let defaultsService = UserDefaultsService()
        defaultsService.storeFilter(filter: tag.rawValue, type: .Tag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
