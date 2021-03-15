//
//  CameraToolbarView.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/15.
//

import UIKit

class CameraToolbarView: UIView {

    @IBOutlet weak var flashButton: UIButton!

    @IBOutlet weak var gridButton: UIButton!

    @IBOutlet weak var ratioButton: UIButton!

    @IBOutlet weak var settingButton: UIButton!

    override func awakeFromNib() {
        flashButton.layer.cornerRadius = 0.5 * flashButton.bounds.size.width
        gridButton.layer.cornerRadius = 0.5 * gridButton.bounds.size.width
        ratioButton.layer.cornerRadius = 0.5 * ratioButton.bounds.size.width
        settingButton.layer.cornerRadius = 0.5 * settingButton.bounds.size.width
        
    }
}
