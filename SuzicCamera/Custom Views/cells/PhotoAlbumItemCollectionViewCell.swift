//
//  PhotoAlbumItemCollectionViewCell.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/02.
//

import UIKit

class PhotoAlbumItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isSelected {
            self.photoImageView.layer.borderColor = CGColor(red: 5, green: 197, blue: 144, alpha: 1)
            self.photoImageView.layer.borderWidth = 1
        } else {
            self.photoImageView.layer.borderColor = UIColor.clear.cgColor
            self.photoImageView.layer.borderWidth = 0
        }
}
    
    override var isSelected: Bool {
        didSet {
            
            if isSelected {
                self.photoImageView.layer.borderColor = CGColor(red: 5, green: 197, blue: 144, alpha: 1)
                self.photoImageView.layer.borderWidth = 1
            } else {
                self.photoImageView.layer.borderColor = UIColor.clear.cgColor
                self.photoImageView.layer.borderWidth = 0
            }
        }
    }
}
