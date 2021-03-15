//
//  MotionManager.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/01.
//

import UIKit
import AVFoundation
import Photos

class MotionManager {
    
    let motionKit = MotionKit() // core motion 수직수평계(중력가속도)측정을 위한 킷
    
    var currentPosition: AVCaptureDevice.Position? // 카메라 포지션을 저장할 프로퍼티
    var rectOfpreviewImage: CGRect? // previewImage의 CGRect
    //var cameraViewPhotoSize: CameraViewPhotoSize? // 카메라 뷰에 담길 촬영 포토 사이즈를 위한 프로퍼티
    var focusBox: UIView! // 초점 박스
    var timerStatus: Int = 0 // 타이머 0초, 3초, 5초, 10초 구분을 위한 프로퍼티
    var setTime: Int = 0 // 타이머 카운트다운을 위한 프로퍼티
    var countTimer: Timer! // 동적 타이머 프로퍼티를 컨트롤하기 위한 정적 프로퍼티
    var isCounting: Bool = false // 타이머가 동작중인지 확인하는 프로퍼티
    var isOn_flash: Bool = false // 플래시 상태 프로퍼티
    var isOn_Grid = true //그리드 뷰 && 버튼 활성화 비활성화 flow controll value
    var isOn_touchCapture: Bool = false // 터치촬영모드 상태 프로퍼티
    var isOn_continuousCapture: Bool = false // 연속촬영모드 상태 프로퍼티
    var currentAngleH: Float = 0.0 // 현재 "수평H" 각도를 저장하는 프로퍼티
    var currentAngleV: Float = 0.0 // 현재 "수직V" 각도를 저장하는 프로퍼티
    var currentAngleY: Float = 0.0 // 가로모드일 때 "수평H"를 대신하는 프로퍼티
    var tempAngleH: Float = 0.0 // "수평H" 각도핀 고정 -> 임시 기준각도를 저장하는 프로퍼티
    var tempAngleV: Float = 0.0 // "수평V" 각도핀 고정 -> 임시 기준각도를 저장하는 프로퍼티
    var isOn_AnglePin = false // 각도 고정핀 상태
    var pageStatus = 0 // 페이지 컨트롤 인터랙션을 위한 프로퍼티
    let pageSize = 3 // 레이아웃 모드의 개수

    var feedbackGenerator: UINotificationFeedbackGenerator?
    var verticalOkHapticFlag: Bool = true
    var horizontalOkHapticFlag: Bool = true
    
    func setFeedbackGenerator() {
        self.feedbackGenerator = UINotificationFeedbackGenerator()
        self.feedbackGenerator?.prepare()
    }
    
    // MARK: horizontal, vertical indicator
    func setGravityAccelerator(horizontalIndicator: UIView,
                               verticalIndicator: UIView,
                               circleIndicator: UIView,
                               verticalIndicatorHeightConstraint: NSLayoutConstraint,
                               circleIndicatorHeightConstraint: NSLayoutConstraint) {

        motionKit.getGravityAccelerationFromDeviceMotion(interval: 0.02) { [self] (x, y, z) in
            // x(H)가 좌-1 우+1, z(V)가 앞-1 뒤+1
            var transform: CATransform3D
            
            let roundedX = Float(round(x * 100)) / 100.0
            self.currentAngleH = roundedX * 90
            
            let roundedZ = Float(round(z * 100)) / 100.0
            self.currentAngleV = roundedZ * 90
            
            let roundedY = Float(round(y * 100)) / 100.0
            self.currentAngleY = roundedY * 90

            // if 임시각도on -> 영점 조절
            if self.isOn_AnglePin == true {
                self.currentAngleH -= self.tempAngleH
            }
            
            transform = CATransform3DIdentity;
            transform.m34 = 1.0/500
            transform = CATransform3DRotate(
                transform,
                CGFloat(self.currentAngleH * Float.pi / 180), 0, 0, 1
            )
            horizontalIndicator.transform3D = transform

            // if 임시각도on -> 영점 조절
            if self.isOn_AnglePin == true {
                self.currentAngleV -= self.tempAngleV
            }
            //print("x: \(roundedX), y:\(roundedY), z:\(roundedZ) currentAngleH: \(currentAngleH), currentAngleV:\(currentAngleV), currentAngleY:\(currentAngleY)")

            checkVerticalBalance(for: verticalIndicator, for: circleIndicator)
            checkHorizontalBalance(for: horizontalIndicator)

            if CGFloat(-currentAngleV) > 0 {

                verticalIndicatorHeightConstraint.constant = 90 - CGFloat(-currentAngleV)
                circleIndicatorHeightConstraint.constant = 90 - CGFloat(-currentAngleV)
            } else if CGFloat(-currentAngleV) < 0 {
                verticalIndicatorHeightConstraint.constant = 90 + CGFloat(-currentAngleV)
                circleIndicatorHeightConstraint.constant = 90 + CGFloat(-currentAngleV)
            }
        }
    }
    
    private func checkVerticalBalance(for verticalIndicator: UIView, for circleIndicator: UIView) {
        if self.currentAngleV < 3 && self.currentAngleV > -3 {
            verticalIndicator.backgroundColor = .systemGreen
            circleIndicator.layer.borderColor = UIColor.systemGreen.cgColor
            if verticalOkHapticFlag {
                self.feedbackGenerator?.notificationOccurred(.success)
                verticalOkHapticFlag = false
            }
        } else {
            verticalIndicator.backgroundColor = .systemRed
            circleIndicator.layer.borderColor = UIColor.systemRed.cgColor
            verticalOkHapticFlag = true
        }
    }
    
    private func checkHorizontalBalance(for horizontalIndicator: UIView) {
        if self.currentAngleH < 3 && self.currentAngleH > -3 {
            horizontalIndicator.backgroundColor = .systemGreen
            if horizontalOkHapticFlag {
                self.feedbackGenerator?.notificationOccurred(.success)
                horizontalOkHapticFlag = false
            }
        } else {
            horizontalIndicator.backgroundColor = .systemRed
            horizontalOkHapticFlag = true
        }
    }
}
