//
//  ActivityBarController.swift
//  LineChartExample
//
//  Created by Marcus Thuvesen on 2019-03-23.
//  Copyright © 2019 Osian. All rights reserved.
//

import UIKit
import CoreMotion

class ActivityBarController: UIViewController {

    @IBOutlet weak var startBtnOutlet: UIButton!
    @IBOutlet weak var restartBtnOutlet: UIButton!
    @IBOutlet weak var leftThumbBtnOutlet: UIButton!
    @IBOutlet weak var rightThumbBtnOutlet: UIButton!
    @IBOutlet weak var healthBarView: UIView!
    @IBOutlet weak var healthView: UIView!
    @IBOutlet weak var healthWidth: NSLayoutConstraint!
    @IBOutlet weak var percentageLabel: UILabel!
    
    
    var isDeviceMotionOn = false
    var regenerationArray : [Double] = []
    var accZXArray : [Double] = []
    var gravityXArray : [Double] = []
    var gravityYArray : [Double] = []
    var accelerationZArray : [Double] = []
    var accelerationXArray : [Double] = []
    var activityFactorArray : [Double] = [0]
    let motionManager = CMMotionManager()
    var acceleration : Double = 0
    var timeInterval : Double = 30
    var batchNumbersArray = [Double]()
    var lastActivityCheat = false
    var gravX : Double = 0
    var gravY : Double = 0
    var accY : Double = 0
    var accZ : Double = 0
    var accX : Double = 0
    var activityFactor : Double = 0
    var temporaryTapDetection : Double?
    var tapCheatDetected = false
    let lowerLimit : Double = 0.25
    let upperLimit : Double = 1.4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        healthBarView.layer.cornerRadius = 15
        healthView.layer.cornerRadius = 15
        startBtnOutlet.layer.cornerRadius = startBtnOutlet.frame.height / 2
        restartBtnOutlet.layer.cornerRadius = restartBtnOutlet.frame.height / 2
        leftThumbBtnOutlet.tintColor = .white
        rightThumbBtnOutlet.tintColor = .white
    }
    
    
    
    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                let x = abs(motion.userAcceleration.x)
                let z = abs(motion.userAcceleration.z)
            
                self.acceleration = round((x+z) * 100) / 100
        
                
                let gravity = motion.gravity
                OperationQueue.main.addOperation {
                    self.cheatingFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
                    
                }
            }
        }
    }
    
    func cheatingFilter(gravity : CMAcceleration, acceleration : Double, motion : CMDeviceMotion){
        
        //When hit hard, not normal behaviour
        if accZXArray.count < 5{
            gravityXArray.append(abs(gravity.x))
            gravityYArray.append(abs(gravity.y))
            accelerationZArray.append(abs(motion.userAcceleration.z))
            accelerationXArray.append(abs(motion.userAcceleration.x))
            self.accZXArray.append(acceleration)
        }
        else{
            gravX = calculateActivityFactor(activityArray: gravityXArray)
            gravY = calculateActivityFactor(activityArray: gravityYArray)
            accX = calculateActivityFactor(activityArray: accelerationXArray)
            accZ = calculateActivityFactor(activityArray: accelerationZArray)
            activityFactor = calculateActivityFactor(activityArray: accZXArray)
            print("ActivityFactor \(activityFactor)")
            
            //activityFactorArray.append(activityFactor)
            
            if let temporaryTapDetection = temporaryTapDetection {
                if temporaryTapDetection > activityFactor + 0.3 || temporaryTapDetection < activityFactor - 0.3{
                    print("Tap Cheat Detection")
                    tapCheatDetected = true
                }
                else{
                    tapCheatDetected = false
                }
            }
            temporaryTapDetection = activityFactor
            
            if self.gravX > 0.5 && gravY < 0.25 && accZ < 0.65 && accY < 0.6 && self.activityFactor > 0.25 && self.activityFactor < 1.4 && tapCheatDetected == false && leftThumbBtnOutlet.tintColor == .green && rightThumbBtnOutlet.tintColor == .green{
                //Accepted
                changeHealth()
                self.view.backgroundColor = .green
              
            }
            else{
              
                cheatingDetected(str : "Fusk")
            }
            
            //Reset after each batch
            accZXArray.removeAll()
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
    
    
    // Function for users speed
    func calculateActivityFactor(activityArray : Array<Double>) -> Double {
        
        // Calculate sum of array
        let activitySum = activityArray.reduce(0) { $0 + $1 }
        
        // Get the speed of activity by dividing sum of values with nodes/.count
        let activityFactor = activitySum / Double(activityArray.count)
        if activityFactor > 0.1{
            //print("ActivityFactor: \(activityFactor)")
            return activityFactor
        }
        else{
            return 0
        }
    }
    
    func cheatingDetected(str : String){
        //print(str)
        self.lastActivityCheat = true
        self.view.backgroundColor = .red
    }
    
    
    func changeHealth(){
        let parentViewWidth = healthView.bounds.width
        
        if healthWidth.constant < parentViewWidth{
            healthWidth.constant += CGFloat(parentViewWidth/20)
        }
    }
    
    @IBAction func startBtn(_ sender: UIButton) {
        if motionManager.isDeviceMotionAvailable{
            if isDeviceMotionOn == false{
                isDeviceMotionOn = true
                startAccelerometer()
                startBtnOutlet.setTitle("Stoppa", for: .normal)
            }
            else{
                isDeviceMotionOn = false
                motionManager.stopDeviceMotionUpdates()
                startBtnOutlet.setTitle("Starta", for: .normal)
            }
        }
    }
    
    @IBAction func restartBtn(_ sender: UIButton) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.stopDeviceMotionUpdates()
            resetAllValues()
            reloadInputViews()
            startBtnOutlet.setTitle("Stoppa", for: .normal)
            motionManager.startDeviceMotionUpdates()
            startAccelerometer()
            isDeviceMotionOn = true
        }
    }
    
    @IBAction func leftThumbLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            //   print("Vänster Godkänd")
            leftThumbBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            leftThumbBtnOutlet.tintColor = .white
        }
    }
    
    @IBAction func rightThumbLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began{
            //print("Höger Godkänd")
            rightThumbBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            rightThumbBtnOutlet.tintColor = .white
        }
    }
    
    func resetAllValues(){
        gravityXArray.removeAll()
        gravityYArray.removeAll()
        accelerationZArray.removeAll()
        accZXArray.removeAll()
    }
    
}
