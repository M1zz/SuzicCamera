//
//  UIImage+Extension.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/02/28.
//

import UIKit

extension UIImage {
    
    func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        
        let rotatedViewBox = UIView(frame: CGRect(origin: .zero, size: size))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: degrees.toRadians())
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        if let bitmap = UIGraphicsGetCurrentContext() {
            
            bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            bitmap.rotate(by: degrees.toRadians())
            bitmap.scaleBy(x: 1.0, y: -1.0)
            
            if let cgImage = self.cgImage {
                bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            }
            
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { debugPrint("Failed to rotate image. Returning the same as input..."); return self }
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            debugPrint("Failed to create graphics context. Returning the same as input...")
            return self
        }
    }
}

extension CGFloat {
    
    func toRadians() -> CGFloat {
        return self * .pi / 180
    }
    
    func toDegrees() -> CGFloat {
        return self * .pi * 180
    }
}
