//
//  jumpFilter.swift
//  LineChartExample
//
//  Created by Marcus Thuvesen on 2019-04-02.
//  Copyright © 2019 Osian. All rights reserved.
//

import Foundation
import CoreMotion

extension ViewController{
    func jumpFilter(gravity : CMAcceleration, accelerationX : Double, motion : CMDeviceMotion){
        
        if accXArray.count < 5{
            gravityXArray.append(abs(gravity.x))
            gravityYArray.append(abs(gravity.y))
            gravityZArray.append(abs(gravity.z))
            accelerationZArray.append(abs(motion.userAcceleration.z))
            accelerationXArray.append(abs(motion.userAcceleration.x))
            accXArray.append(accelerationX)
        }
        else{
            gravX = calculateActivityFactor(activityArray: gravityXArray)
            gravY = calculateActivityFactor(activityArray: gravityYArray)
            gravZ = calculateActivityFactor(activityArray: gravityZArray)
            accX = calculateActivityFactor(activityArray: accelerationXArray)
            accZ = calculateActivityFactor(activityArray: accelerationZArray)
            activityFactorX = calculateActivityFactorX(activityArrayX: accXArray)
            
            
            
            if activityFactorX < -0.2 && activityFactorX > -2.5 && firstHighValue != true{
                print(activityFactorX)
                print("LowValue")
                firstLowValue = true
            }
                
            else if activityFactorX > 0.2 && firstLowValue == true{
                print(activityFactorX)
                print("HighValue")
                firstHighValue = true
            }
            
            if firstLowValue && firstHighValue && leftBtnOutlet.tintColor == .green && rightBtnOutlet.tintColor == .green{
                print("Hopp")
                firstHighValue = false
                firstLowValue = false
                self.acceptedOrNotView.backgroundColor = .green
                UpdateRegenerationLine(activityFactor: 0.5)
                jumpFilterMemoryBool = true
                jumpFilterCounter = 0
            }
                
            else if jumpFilterCounter < 3 && jumpFilterMemoryBool{
                jumpFilterCounter += 1
                self.acceptedOrNotView.backgroundColor = .green
                UpdateRegenerationLine(activityFactor: 1.5)
                
            }
                //If value over 0 keep the value for a while so the line doesn't drop while in beetween reps
                
            else{
                UpdateRegenerationLine(activityFactor: 0)
                jumpFilterMemoryBool = false
                cheatingDetected(str : "Fusk")
            }
            
            //Reset after each batch
            accYXArray.removeAll()
            accXArray.removeAll()
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
