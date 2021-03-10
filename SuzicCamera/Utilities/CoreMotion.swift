//
//  CoreMotion.swift
//  SuzicCamera
//
//  Created by 이현호 on 2021/03/01.
//

import Foundation
import CoreMotion
import UIKit


@objc protocol MotionKitDelegate {
    @objc optional  func retrieveAccelerometerValues (x: Double, y:Double, z:Double, absoluteValue: Double)
    @objc optional  func retrieveGyroscopeValues     (x: Double, y:Double, z:Double, absoluteValue: Double)
    @objc optional  func retrieveDeviceMotionObject  (deviceMotion: CMDeviceMotion)
    @objc optional  func retrieveMagnetometerValues  (x: Double, y:Double, z:Double, absoluteValue: Double)
    
    @objc optional  func getAccelerationValFromDeviceMotion        (x: Double, y:Double, z:Double)
    @objc optional  func getGravityAccelerationValFromDeviceMotion (x: Double, y:Double, z:Double)
    @objc optional  func getRotationRateFromDeviceMotion           (x: Double, y:Double, z:Double)
    @objc optional  func getMagneticFieldFromDeviceMotion          (x: Double, y:Double, z:Double)
    @objc optional  func getAttitudeFromDeviceMotion               (attitude: CMAttitude)
}


@objc(MotionKit) public class MotionKit :NSObject{
    
    let manager = CMMotionManager()
    var delegate: MotionKitDelegate?

    public override init(){
        NSLog("MotionKit has been initialised successfully")
    }
    

    public typealias DeviceOrientationHandler = ((_ deviceOrientation: UIDeviceOrientation) -> Void)?
    private var deviceOrientationAction: DeviceOrientationHandler?
    private var currentDeviceOrientation: UIDeviceOrientation = .portrait
    private let motionLimit: Double = 1 // Smallers values makes it much sensitive to detect an orientation change. [0 to 1]

    public func startDeviceOrientationNotifier(with handler: DeviceOrientationHandler) {
        self.deviceOrientationAction = handler
        
        manager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if let accelerometerData = data {
                
                var newDeviceOrientation: UIDeviceOrientation?
                
                if (accelerometerData.acceleration.x >= self.motionLimit) {
                    newDeviceOrientation = .landscapeLeft
                }
                else if (accelerometerData.acceleration.x <= -self.motionLimit) {
                    newDeviceOrientation = .landscapeRight
                }
                else if (accelerometerData.acceleration.y <= -self.motionLimit) {
                    newDeviceOrientation = .portrait
                }
                else if (accelerometerData.acceleration.y >= self.motionLimit) {
                    //newDeviceOrientation = .portraitUpsideDown
                }
                else {
                    return
                }
                
                // Only if a different orientation is detect, execute handler
                if newDeviceOrientation != self.currentDeviceOrientation {
                    self.currentDeviceOrientation = newDeviceOrientation ?? .portrait
                    if let deviceOrientationHandler = self.deviceOrientationAction {
                        DispatchQueue.global(qos: .background).async {
                            print("current device orientation: \(String(describing: newDeviceOrientation?.rawValue))")
                            deviceOrientationHandler!(self.currentDeviceOrientation)
                        }
                    }
                }
            }
        }
    }
    
    
    public func getAccelerometerValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y: Double, _ z: Double) -> ())? ){
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isAccelerometerAvailable {
            manager.accelerometerUpdateInterval = interval
            manager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: {
                (data, error) in
                
                if let isError = error {
                    NSLog("Error: \(isError)")
                }
                valX = data!.acceleration.x
                valY = data!.acceleration.y
                valZ = data!.acceleration.z
                
                if values != nil{
                    values!(valX,valY,valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ

                
                let absoluteVal = sqrt(powX + powY + powZ)
                self.delegate?.retrieveAccelerometerValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            })
        } else {
            NSLog("The Accelerometer is not available")
        }
    }

    
    public func getGyroValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y: Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isGyroAvailable {
            manager.gyroUpdateInterval = interval
            manager.startGyroUpdates(to: OperationQueue.main, withHandler: {
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.rotationRate.x
                valY = data!.rotationRate.y
                valZ = data!.rotationRate.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ

                
                let absoluteVal = sqrt(powX + powY + powZ)
                self.delegate?.retrieveGyroscopeValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            })
            
        } else {
            NSLog("The Gyroscope is not available")
        }
    }

    
    @available(iOS, introduced: 5.0)
    public func getMagnetometerValues (interval: TimeInterval = 0.1, values: ((_ x: Double, _ y:Double, _ z:Double) -> ())? ){
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isMagnetometerAvailable {
            manager.magnetometerUpdateInterval = interval
            manager.startMagnetometerUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.magneticField.x
                valY = data!.magneticField.y
                valZ = data!.magneticField.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                let powX = valX * valX
                let powY = valY * valY
                let powZ = valZ * valZ
                
                let absoluteVal = sqrt(powX + powY + powZ)
                
                self.delegate?.retrieveMagnetometerValues!(x: valX, y: valY, z: valZ, absoluteValue: absoluteVal)
            }
            
        } else {
            NSLog("Magnetometer is not available")
        }
    }
    
   
    public func getDeviceMotionObject (interval: TimeInterval = 0.1, values: ((_ deviceMotion: CMDeviceMotion) -> ())? ) {
        
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                if values != nil{
                    values!(data!)
                }
                self.delegate?.retrieveDeviceMotionObject!(deviceMotion: data!)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    public func getAccelerationFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.userAcceleration.x
                valY = data!.userAcceleration.y
                valZ = data!.userAcceleration.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                self.delegate?.getAccelerationValFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is unavailable")
        }
    }
    
   
    public func getGravityAccelerationFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.gravity.x
                valY = data!.gravity.y
                valZ = data!.gravity.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                self.delegate?.getGravityAccelerationValFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    public func getAttitudeFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ attitude: CMAttitude) -> ())? ) {
        
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                if values != nil{
                    values!(data!.attitude)
                }
                
                self.delegate?.getAttitudeFromDeviceMotion!(attitude: data!.attitude)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
   
    public func getRotationRateFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.rotationRate.x
                valY = data!.rotationRate.y
                valZ = data!.rotationRate.z
                
                if values != nil{
                    values!(valX, valY, valZ)
                }
                
                //let absoluteVal = sqrt(valX * valX + valY * valY + valZ * valZ)
                self.delegate?.getRotationRateFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    public func getMagneticFieldFromDeviceMotion (interval: TimeInterval = 0.1, values: ((_ x:Double, _ y:Double, _ z:Double, _ accuracy: Int32) -> ())? ) {
        
        var valX: Double!
        var valY: Double!
        var valZ: Double!
        var valAccuracy: Int32!
        if manager.isDeviceMotionAvailable{
            manager.deviceMotionUpdateInterval = interval
            manager.startDeviceMotionUpdates(to: OperationQueue.main){
                 (data, error) in
                
                if let isError = error{
                    NSLog("Error: \(isError)")
                }
                valX = data!.magneticField.field.x
                valY = data!.magneticField.field.y
                valZ = data!.magneticField.field.z
                valAccuracy = data!.magneticField.accuracy.rawValue
                
                if values != nil{
                    values!(valX, valY, valZ, valAccuracy)
                }
                
                self.delegate?.getMagneticFieldFromDeviceMotion!(x: valX, y: valY, z: valZ)
            }
            
        } else {
            NSLog("Device Motion is not available")
        }
    }
    
    
    public func getAccelerationAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getAccelerationFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    public func getGravitationalAccelerationAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getGravityAccelerationFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    public func getAttitudeAtCurrentInstant (values: @escaping (_ attitude: CMAttitude) -> ()){
        self.getAttitudeFromDeviceMotion(interval: 0.5) { (attitude) -> () in
            values(attitude)
            self.stopDeviceMotionUpdates()
        }
    
    }
    
    public func getMageticFieldAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getMagneticFieldFromDeviceMotion(interval: 0.5) { (x, y, z, accuracy) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
    public func getGyroValuesAtCurrentInstant (values: @escaping (_ x:Double, _ y:Double, _ z:Double) -> ()){
        self.getRotationRateFromDeviceMotion(interval: 0.5) { (x, y, z) -> () in
            values(x,y,z)
            self.stopDeviceMotionUpdates()
        }
    }
    
   
    public func stopAccelerometerUpdates(){
        self.manager.stopAccelerometerUpdates()
        NSLog("Accelaration Updates Status - Stopped")
    }
    
    
    public func stopGyroUpdates(){
        self.manager.stopGyroUpdates()
        NSLog("Gyroscope Updates Status - Stopped")
    }
    
   
    public func stopDeviceMotionUpdates() {
        self.manager.stopDeviceMotionUpdates()
        NSLog("Device Motion Updates Status - Stopped")
    }
    
    
    @available(iOS, introduced: 5.0)
    public func stopmagnetometerUpdates() {
        self.manager.stopMagnetometerUpdates()
        NSLog("Magnetometer Updates Status - Stopped")
    }
    
}

