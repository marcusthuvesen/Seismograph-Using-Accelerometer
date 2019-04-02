//
//  stampFilter.swift
//  LineChartExample
//
//  Created by Marcus Thuvesen on 2019-04-02.
//  Copyright © 2019 Osian. All rights reserved.
//

import Foundation
import CoreMotion

extension ViewController{
    func stampFilter(gravity : CMAcceleration, acceleration : Double, motion : CMDeviceMotion){
        
        if accYXArray.count < 5{
            gravityXArray.append(abs(gravity.x))
            gravityYArray.append(abs(gravity.y))
            gravityZArray.append(abs(gravity.z))
            accelerationZArray.append(abs(motion.userAcceleration.z))
            accelerationXArray.append(abs(motion.userAcceleration.x))
            self.accYXArray.append(acceleration)
        }
        else{
            gravX = calculateActivityFactor(activityArray: gravityXArray)
            gravY = calculateActivityFactor(activityArray: gravityYArray)
            gravZ = calculateActivityFactor(activityArray: gravityZArray)
            accX = calculateActivityFactor(activityArray: accelerationXArray)
            accZ = calculateActivityFactor(activityArray: accelerationZArray)
            activityFactor = calculateActivityFactor(activityArray: accYXArray)
            //print("ActivityFactor \(activityFactor)")
            
            if let temporaryTapDetection = temporaryTapDetection {
                if temporaryTapDetection > activityFactor + 0.8 || temporaryTapDetection < activityFactor - 0.8{
                    print("Tap Cheat Detection")
                    tapCheatDetected = true
                }
                else{
                    tapCheatDetected = false
                }
            }
            temporaryTapDetection = activityFactor
            
            if self.gravX < 0.8 {
                print("Ogiltlig X")
            }
            if self.gravY > 0.25 {
                print("ogiltlig y")
            }
            if gravity.z > 0.3 {
                print("ogiltlig z")
            }
            if accZ > 0.8 {
                print("Accel z ogl")
            }
            if accY > 0.8 {
                print("accY ogiltlig")
            }
            if activityFactor < 0.15 || activityFactor > 1.5 {
                print(activityFactor)
            }
            // Filter
            if gravX > 0.8 && gravY < 0.25 && gravZ < 0.3 && accZ < 0.8 && accY < 0.8 && activityFactor > 0.1 && activityFactor < 1.7 && tapCheatDetected == false && leftBtnOutlet.tintColor == .green && rightBtnOutlet.tintColor == .green{
                //Accepted
                self.acceptedOrNotView.backgroundColor = .green
                UpdateRegenerationLine(activityFactor: activityFactor)
            }
            else{
                UpdateRegenerationLine(activityFactor: 0)
                cheatingDetected(str : "Fusk")
            }
            
            //Reset after each batch
            accYXArray.removeAll()
            gravityXArray.removeAll()
            gravityYArray.removeAll()
            accelerationZArray.removeAll()
            accelerationXArray.removeAll()
            activityFactor = 0
            gravX = 0
            gravY = 0
            accY = 0
            accZ = 0
        }
    }
}
