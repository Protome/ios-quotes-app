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
    var selectedColours: [UIColor]?
    var colourType:String?
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.done,target: self, action: #selector(SaveChanges))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        styleView()
        
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        DispatchQueue.main.async {
            self.CollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
            self.collectionView(self.CollectionView, didSelectItemAt: indexPath)
        }
    }
    
    func styleView()
    {
        colourPickerTopRight = ChromaColorPicker(frame: TopRightColourPicker.bounds)
        colourPickerTopRight!.padding = 5
        colourPickerTopRight!.stroke = 3
        colourPickerTopRight!.hexLabel.textColor = UIColor.white
        colourPickerTopRight!.colorToggleButton.isHidden = true
        colourPickerTopRight!.addButton.isHidden = true
        colourPickerTopRight!.addTarget(self, action: #selector(ColourChanged), for: UIControl.Event.valueChanged)
        
        colourPickerBottomLeft = ChromaColorPicker(frame: BottomLeftColourPIcker.bounds)
        colourPickerBottomLeft!.padding = 5
        colourPickerBottomLeft!.stroke = 3
        colourPickerBottomLeft!.hexLabel.textColor = UIColor.white
        colourPickerBottomLeft!.colorToggleButton.isHidden = true
        colourPickerBottomLeft!.addButton.isHidden = true
        colourPickerBottomLeft!.addTarget(self, action: #selector(ColourChanged), for: UIControl.Event.valueChanged)
        
        TopRightColourPicker.addSubview(colourPickerTopRight!)
        BottomLeftColourPIcker.addSubview(colourPickerBottomLeft!)
        
        colourPickerTopRight?.isHidden = colourType != "Custom"
        colourPickerBottomLeft?.isHidden = colourType != "Custom"
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
    
    @objc func ColourChanged(control:ChromaColorPicker, withEvent event: UIEvent)
    {
        guard colourType == "Custom" else {
            return
        }
        
        let colours = [colourPickerTopRight?.currentColor ?? UIColor(named: "BlueGradientLight")!,
                       colourPickerBottomLeft?.currentColor ?? UIColor(named: "BlueGradientDark")!]
        
        updatePreview(selectedColours: colours)
        selectedColours = colours
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
        
        colourType = gradientName
        
        if gradientName == "Custom",  let colours = userDefaultService.loadColours()
        {
            colourPickerTopRight?.adjustToColor(colours[0])
            colourPickerBottomLeft?.adjustToColor(colours[1])
            selectedColours = colours
        }
        
        colourPickerTopRight?.isHidden = colourType != "Custom"
        colourPickerBottomLeft?.isHidden = colourType != "Custom"
        
        updatePreview(selectedColours: selectedColours)
    }
    
    @objc func SaveChanges() {
        guard let selectedType = colourType else {
            return
        }
    
        userDefaultService.storeBackgroundType(type: selectedType)
        
        if selectedType == "Custom", let colours = selectedColours
        {
            userDefaultService.storeColours(colours: colours)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

protocol ColourSelectionDelegate: class
{
    func coloursSelected(colours: [UIColor])
}
