//
//  YawOperation.swift
//  TestBed
//
//  Created by Chris Searle on 06/12/2016.
//  Copyright © 2016 Chris Searle. All rights reserved.
//

import UIKit
import DJISDK

class AttitudeOperation: NSOperation, DJIGimbalDelegate {
    
    let gimbal : DJIGimbal
    let pitch : Float
    let roll : Float
    let yaw : Float
    
    var currentPitch : Float = -1000
    var currentRoll : Float = -1000
    var currentYaw : Float = -1000
    
    var error : NSError?
    
    let allowedOffset: Float = 2.5

    init(gimbal: DJIGimbal, pitch: Float, roll: Float, yaw: Float) {
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
        self.gimbal = gimbal
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        
        var yawRotation = DJIGimbalAngleRotation()
        var rollRotation = DJIGimbalAngleRotation()
        var pitchRotation = DJIGimbalAngleRotation()
        
        pitchRotation.enabled = ObjCBool(true)
        yawRotation.enabled = ObjCBool(true)
        rollRotation.enabled = ObjCBool(true)
        
        pitchRotation.angle = pitch
        yawRotation.angle = yaw
        rollRotation.angle = roll
        
        self.gimbal.rotateGimbalWithAngleMode(.AngleModeAbsoluteAngle, pitch: pitchRotation, roll: rollRotation, yaw: yawRotation, withCompletion: {
            (error) in
            
            self.error = error
        })
     
        repeat {
            if self.cancelled {
                return
            }
        } while (stillNeedsToMove())
    }

    func gimbal(gimbal: DJIGimbal, didUpdateGimbalState gimbalState: DJIGimbalState) {
        let atti = gimbalState.attitudeInDegrees
        
        self.currentPitch = atti.pitch
        self.currentYaw = atti.yaw
        self.currentRoll = atti.roll
    }

    func stillNeedsToMove() -> Bool {
        return valueInRange(self.pitch, currentValue: self.currentPitch) &&
        valueInRange(self.roll, currentValue: self.currentRoll) &&
        valueInRange(self.yaw, currentValue: self.currentYaw)
    }
    
    
    func valueInRange(value: Float, currentValue: Float) -> Bool {
        return ((value - allowedOffset) ... (value + allowedOffset) ~= currentValue)
    }
}
