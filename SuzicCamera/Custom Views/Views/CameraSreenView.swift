//
//  CameraSreenView.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/02/28.
//

import UIKit
import AVFoundation

class CameraSreenView: UIView {
    /* Source from Apple documentation
     https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app
     */
    @IBOutlet weak var circleIndicator: UIView!
    @IBOutlet weak var circleIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalIndicator: UIView!
    @IBOutlet weak var verticalIndicator: UIView!
    @IBOutlet weak var verticalIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseline: UIView!
    
    private let motionManager = MotionManager()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func awakeFromNib() {
        configureMotionManager()
        configureCircleIndicator()
    }
    
    
    private func configureMotionManager() {
        motionManager.setFeedbackGenerator()
        motionManager.setGravityAccelerator(horizontalIndicator: horizontalIndicator,
                                            verticalIndicator: verticalIndicator,
                                            circleIndicator: circleIndicator,
                                            verticalIndicatorHeightConstraint: verticalIndicatorHeightConstraint,
                                            circleIndicatorHeightConstraint: circleIndicatorHeightConstraint)
    }
    
    
    private func configureCircleIndicator() {
        circleIndicator.layer.cornerRadius = 0.5 * circleIndicator.bounds.size.width
        circleIndicator.layer.borderWidth = 2
        circleIndicator.backgroundColor = .none
        circleIndicator.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {

        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }

        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }
    
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }

    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
