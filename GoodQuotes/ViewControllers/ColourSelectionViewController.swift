//
//  ColourSelectionViewController.swift
//  GoodQuotes
//
//  Created by Kieran Bamford on 03/06/2019.
//  Copyright © 2019 Protome. All rights reserved.
//

import Foundation
import UIKit
import Pastel
import ChromaColorPicker

class ColourSelectionViewController : UIViewController {
    
    @IBOutlet weak var PreviewGradientView: UIView!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var TopRightColourPicker: UIView!
    @IBOutlet weak var BottomLeftColourPIcker: UIView!
    
    var colourPickerTopRight: ChromaColorPicker?
    var colourPickerBottomLeft: ChromaColorPicker?
    var previewPastelView: PastelView?
    var keys: [String]?
    var selectedIndex: Int = 0
    let userDefaultService = UserDefaultsService()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        keys = GradientsService.ColourMappings.keys.sorted()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        keys = GradientsService.ColourMappings.keys.sorted()
        
        guard let customIndex = keys?.firstIndex(where: {$0 == "Custom"}) else { return }
        let removedCustom = keys?.remove(at: customIndex)
        keys?.append(removedCustom!)
        
        guard let startingIndex = keys?.firstIndex(where: {$0 == userDefaultService.loadBackgroundType()}) else { return }
        let removed = keys?.remove(at: startingIndex)
        keys?.insert(removed!, at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        
        styleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        DispatchQueue.main.async {
            self.CollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
            self.collectionView(self.CollectionView, didSelectItemAt: indexPath)
        }
    }
    
    func styleView()
    {
        TopRightColourPicker.isHidden = true
        BottomLeftColourPIcker.isHidden = true
        
        colourPickerTopRight = ChromaColorPicker(frame: TopRightColourPicker.bounds)
        colourPickerTopRight!.delegate = self
        colourPickerTopRight!.padding = 5
        colourPickerTopRight!.stroke = 3
        colourPickerTopRight!.hexLabel.textColor = UIColor.white
        
        colourPickerBottomLeft = ChromaColorPicker(frame: BottomLeftColourPIcker.bounds)
        colourPickerBottomLeft!.delegate = self
        colourPickerBottomLeft!.padding = 5
        colourPickerBottomLeft!.stroke = 3
        colourPickerBottomLeft!.hexLabel.textColor = UIColor.white
        
        TopRightColourPicker.addSubview(colourPickerTopRight!)
        BottomLeftColourPIcker.addSubview(colourPickerBottomLeft!)
        view.layoutIfNeeded()
    }
    
    func updatePreview(selectedColours: [UIColor])
    {
        previewPastelView?.removeFromSuperview()
        previewPastelView = PastelView(frame: PreviewGradientView.bounds)
        
        previewPastelView!.startPastelPoint = .bottomLeft
        previewPastelView!.endPastelPoint = .topRight
        previewPastelView!.animationDuration = 1.4
        
        previewPastelView!.setColors(selectedColours)
        PreviewGradientView.insertSubview(previewPastelView!, at: 0)
        previewPastelView!.startAnimation()
    }
}

extension ColourSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GradientsService.ColourMappings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GradientCell", for: indexPath) as? GradientCell else {
            return UICollectionViewCell()
        }
        
        cell.setupCell(gradientName: keys![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth = 105
        let cellCount = 3
        let cellSpacing = 15
        
        let totalCellWidth = cellWidth * cellCount
        let totalSpacingWidth = cellSpacing * (cellCount - 1)
        
        let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? GradientCell,
            let gradientName = item.gradientName,
            var selectedColours = GradientsService.ColourMappings[gradientName]
            else {
                return
        }
        
        userDefaultService.storeBackgroundType(type: gradientName)
        
        if gradientName == "Custom",  let colours = userDefaultService.loadColours()
        {
            colourPickerTopRight?.adjustToColor(colours[0])
            colourPickerBottomLeft?.adjustToColor(colours[1])
            selectedColours = colours
        }
        
        TopRightColourPicker.isHidden = gradientName != "Custom"
        BottomLeftColourPIcker.isHidden = gradientName != "Custom"
        
        updatePreview(selectedColours: selectedColours)
    }
}

extension ColourSelectionViewController: ChromaColorPickerDelegate
{
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        let colours = [colourPickerTopRight?.currentColor ?? UIColor(named: "BlueGradientLight")!,
                              colourPickerBottomLeft?.currentColor ?? UIColor(named: "BlueGradientDark")!]
        
        updatePreview(selectedColours: colours)
        userDefaultService.storeColours(colours: colours)
    }
}

protocol ColourSelectionDelegate: class
{
    func coloursSelected(colours: [UIColor])
}
