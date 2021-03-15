//
//  CameraControlView.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/14.
//

import UIKit

// protocol: class 가 무엇인지 정리하자
protocol CameraControlDelegate: class {
    func didTapCaptureButton()
}

class CameraControlView: UIView {

    weak var delegate: CameraControlDelegate!
    @IBOutlet weak var captureButtonView: UIView!
    @IBOutlet weak var captureButtonOutlineView: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var photosAlbumButton: UIButton!
    @IBOutlet weak var cameraStatusView: UIView!
    @IBOutlet weak var cameraToolbarView: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        configureCaptureButton()
    }
    
    
    func configureCaptureButton() {
        captureButtonOutlineView.layer.cornerRadius = 0.5 * captureButtonOutlineView.bounds.size.width
        
        captureButtonView.layer.cornerRadius = 0.5 * captureButtonView.bounds.size.width
        captureButtonView.layer.borderWidth = 2
        captureButtonView.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
}
