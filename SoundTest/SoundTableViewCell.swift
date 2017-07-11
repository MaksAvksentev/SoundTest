//
//  SoundTableViewCell.swift
//  SoundTest
//
//  Created by Maksim Avksentev on 05.07.17.
//  Copyright © 2017 Avksentev. All rights reserved.
//

import UIKit

protocol SoundCellDelegate: class {
    
    func addToFavorites(itemAtIndexPath indexPath: IndexPath)
}

class SoundTableViewCell: UITableViewCell {

    @IBOutlet weak var soundImage: UIImageView!
    @IBOutlet weak var soundTitle: UILabel!
    
    weak var delegate: SoundCellDelegate?
    
    class var className: String {
    
        return "SoundTableViewCell"
    }
    
    class var reuseIdentifier: String {
    
        return self.className
    }
    
    //MARK: - LifeCycle
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.configureAccessoryView()
    }
    
    //MARK: - Private
    private func configureAccessoryView() {
    
        let saveButton = UIButton(type: .custom) as UIButton
        saveButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        saveButton.addTarget(self, action: #selector(SoundTableViewCell.favoriteButtonPressed(_:)), for: .touchUpInside)
        saveButton.setImage(UIImage(named: "favorite"), for: .normal)
        saveButton.tintColor = UIColor.black
        
        self.accessoryView = saveButton as UIView
    }
    
    //MARK: - Actions
    func favoriteButtonPressed(_ sender: UIButton) {
        
        guard let index = self.accessoryView?.tag else {
        
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        self.delegate?.addToFavorites(itemAtIndexPath: indexPath)
    }
    
    //MARK: - Nib
    class func nib() -> UINib {
        
        return UINib(nibName: self.className, bundle: nil)
    }
}
