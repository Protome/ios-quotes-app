//
//  ColourSelectionViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 03/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit

class ColourSelectionViewController : UIViewController {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
    }
    
}

extension ColourSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GradientsService.ColourMappings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradientCell", for: indexPath) as? GradientCell else {
            return UICollectionViewCell()
        }
        
        cell.setupCell(gradientName: Array(GradientsService.ColourMappings.keys)[indexPath.row])
        return cell
    }
}

protocol ColourSelectionDelegate: class
{
    func coloursSelected(colours: [UIColor])
}
