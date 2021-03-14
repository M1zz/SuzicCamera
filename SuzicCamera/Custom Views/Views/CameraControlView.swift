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
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var photosAlbumButton: UIButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        captureButtonView.layer.cornerRadius = 0.5 * captureButtonView.bounds.size.width
    }
    
}
