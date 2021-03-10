//
//  CameraViewController.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/02/28.
//

import UIKit
import AVFoundation
import Photos


class CameraViewController: UIViewController {
    
    private let photoOutput = AVCapturePhotoOutput()
    
    //private var isFlashOn: Bool = false // 플래시 상태 프로퍼티


    @IBOutlet weak var cameraSreenView: CameraSreenView!
    @IBOutlet weak var captureButtonView: UIView!
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var photosAlbumButton: UIButton!
    
    private let motionManager = MotionManager()
    var authorizationStatus: PHAuthorizationStatus? // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티-3
    var imageManger: PHCachingImageManager?
    var assetsFetchResults: PHFetchResult<PHAsset>! // 포토앨범 썸네일 1장 불러오기 위한 프로퍼티-1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSessions()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // self.checkTutorial()
        super.viewDidAppear(animated)
        setLatestPhoto()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SessionManager.shared.stopSession()
        motionManager.motionKit.stopDeviceMotionUpdates()
    }
    
    
    private func configureSessions() {
        cameraSreenView.session = SessionManager.shared.captureSession
        SessionManager.shared.configureSessions(photoOutput: self.photoOutput)
    }
    
    
    @IBAction func switchCamera(sender: Any) {
        if checkDeviceHasMoreCamera() {
            SessionManager.shared.switchSession()
        }
    }
    
    
    @IBAction func tapCaptureButton(_ sender: Any) {
        let videoPreviewLayerOrientation =
            self.cameraSreenView.videoPreviewLayer.connection?.videoOrientation
        
        DispatchQueue.global(qos: .userInitiated).async {
            let connection = self.photoOutput.connection(with: .video)
            connection?.videoOrientation = videoPreviewLayerOrientation!
            
            let setting = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: setting, delegate: self)
        }
    }
    
    
    private func savePhotoLibrary(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (_, error) in
                    //self.setLatestPhoto() // 앨범버튼 썸네일 업데이트
                }
            } else {
                print(" error to save photo library")
            }
        }
    }
    
    
    private func checkDeviceHasMoreCamera() -> Bool {
        return SessionManager.shared.videoDeviceDiscoverySession.devices.count > 1
    }

    
    private func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width // 새 이미지 확대/축소 비율
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    private func cropImageWithRatio (image : UIImage, rect : CGRect, scale : CGFloat)-> UIImage? {
        UIGraphicsBeginImageContextWithOptions (
            CGSize (width : rect.size.width / scale, height : rect.size.height / scale), true, 0.0)
        image.draw (at : CGPoint (x : -rect.origin.x / scale, y : -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext ()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    
    private func setLatestPhoto(){
        
        PHPhotoLibrary.authorizationStatus()
        
        authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if let authorizationStatusOfPhoto = authorizationStatus {
            switch authorizationStatusOfPhoto {
            case .authorized:
                self.imageManger = PHCachingImageManager()
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                
                let asset: PHAsset = self.assetsFetchResults![0]
                
                self.imageManger?.requestImage(for: asset,
                                               targetSize: CGSize(width: 40, height: 40),
                                               contentMode: PHImageContentMode.aspectFill,
                                               options: nil,
                                               resultHandler: { (result : UIImage?, info) in
                                                DispatchQueue.main.async {
                                                    self.photosAlbumButton.setImage(result, for: .normal)
                                                    self.photosAlbumButton.layer.cornerRadius = 10
                                                    self.photosAlbumButton.layer.masksToBounds = true
                                                    self.photosAlbumButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                                                    self.photosAlbumButton.layer.borderWidth = 1
                                                }
                                                })
                //self.photoAlbumCollectionView?.reloadData()
           
            case .denied:
                print(authorizationStatusOfPhoto)
            case .notDetermined:
                print(authorizationStatusOfPhoto)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                    print(authorizationStatus.rawValue)
                })
            case .restricted:
                print(authorizationStatusOfPhoto)
            case .limited:
                print("접근제한(.limited): \(authorizationStatusOfPhoto)")
            @unknown default:
                print("@unknown error: \(authorizationStatusOfPhoto)")
            }
        }
    }
    
}


extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        var croppedImage: UIImage = image
        let rectRatio = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.width*4.0/3.0)
        croppedImage = cropImageWithRatio(image: image, rect: rectRatio, scale: 1.0) ?? image

        self.savePhotoLibrary(image: resizeImage(image: croppedImage, newWidth: 1080))
    }
}



