//
//  CameraToolbarView.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/15.
//

import UIKit
import AVFoundation

class CameraToolbarView: UIView {

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var gridButton: UIButton!
    @IBOutlet weak var ratioButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!

    private var flashToggle: Bool = false
    
    override func awakeFromNib() {
        flashButton.layer.cornerRadius = 0.5 * flashButton.bounds.size.width
        gridButton.layer.cornerRadius = 0.5 * gridButton.bounds.size.width
        ratioButton.layer.cornerRadius = 0.5 * ratioButton.bounds.size.width
        settingButton.layer.cornerRadius = 0.5 * settingButton.bounds.size.width
        
        chageFlashStatusIcon()
    }
    
    
    @IBAction func didTapFlashButton(_ sender: Any) {
        flashToggle.toggle()
        chageFlashStatusIcon()
        print("Flash \(flashToggle)")
    }

    
    private func chageFlashStatusIcon() {
        switch flashToggle {
        case true:
            flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        case false:
            flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        }
        print(flashButton.currentImage?.description)
    }
    func getFlashMode() -> AVCaptureDevice.FlashMode {
        var valueOfAVCaptureFlashMode: AVCaptureDevice.FlashMode = .off
        
        switch flashToggle {
        case false:
            valueOfAVCaptureFlashMode = .off
        case true:
            valueOfAVCaptureFlashMode = .on
        }
        return valueOfAVCaptureFlashMode
    }

    
    @IBAction func didTapGridButton(_ sender: Any) {
        print("grid On/Off")
    }
    
    @IBAction func didTapChangeRatioButton(_ sender: Any) {
        print("Ratio On/Off")
    }
    
    
    @IBAction func didTapSettingButton(_ sender: Any) {
        print("Get Setting Page")
    }
    
}
