//
//  SessionManager.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/01.
//

import UIKit
import AVFoundation

class SessionManager {
    
    static let shared = SessionManager()
    let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session Queue")
    private var videoDeviceInput: AVCaptureDeviceInput!
    let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera, .builtInTrueDepthCamera],
        mediaType: .video,
        position: .unspecified
    )
    
    private init() {}
    
    func configureSessions(photoOutput: AVCapturePhotoOutput) {
        sessionQueue.async {
            self.setupSession(photoOutput: photoOutput)
            self.startSession()
        }
    }
    
    private func setupSession(photoOutput: AVCapturePhotoOutput) {
        
        captureSession.sessionPreset = .photo
        captureSession.beginConfiguration()
        
        guard let camera = videoDeviceDiscoverySession.devices.first else {
            captureSession.commitConfiguration()
            return
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                captureSession.commitConfiguration()
                return
            }
            
        } catch let error {
            captureSession.commitConfiguration()
            // TODO: error log
            print(error)
            return
        }
        
        photoOutput.setPreparedPhotoSettingsArray(
            [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
            completionHandler: nil
        )
        if captureSession.canAddOutput(photoOutput){
            captureSession.addOutput(photoOutput)
        } else {
            captureSession.commitConfiguration()
            return
        }
        captureSession.commitConfiguration()
    }
    

    func startSession() {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchSession() {
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            let isFront = currentPosition == .front
            let preferredPosition: AVCaptureDevice.Position = isFront ? .back : .front
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice?
            
            newVideoDevice = devices.first(where: { device in
                return preferredPosition == device.position
            })
            
            // update capture session
            if let newDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: newDevice)
                    self.captureSession.beginConfiguration()
                    self.captureSession.removeInput(self.videoDeviceInput)
                    
                    // 새로 찾은 videoDeviceInput을 넣을 수 있으면 // 새로운 디바이스 인풋을 넣음
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else { // 아니면 그냥 원래 있던거 다시 넣고
                        self.captureSession.addInput(self.videoDeviceInput) // 이 조건문 다시보기
                    }
                    self.captureSession.commitConfiguration()
                    
                    // 카메라 전환 토글 버튼 업데이트
                    // UI관련 작업은 Main Queue에서 수행되어야 함
                    
//                    DispatchQueue.main.async {
//                        self.updateSwitchCameraIcon(position: preferredPosition)
//                    }
                    
                } catch let error {
                    print("error occured while creating device input: \(error.localizedDescription)")
                }
            }
        }
    }
    
//    func updateSwitchCameraIcon(position: AVCaptureDevice.Position) {
//        // TODO: Update ICON
//        switch position {
//        case .front:
//            let image = UIImage(named: "ic_camera_front")
//            switchButton.setImage(image, for: .normal)
//        case .back:
//            let image = UIImage(named: "ic_camera_front")
//            switchButton.setImage(image, for: .normal)
//        default:
//            break
//        }
//
//    }
    
}
