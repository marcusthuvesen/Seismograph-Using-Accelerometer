//
//  ViewController.swift
//  LineChartExample
//
//  Created by Osian on 13/07/2017.
//  Copyright © 2017 Osian. All rights reserved.
//

import UIKit
import Charts // You need this line to be able to use Charts Library
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var chtChart: LineChartView!
     var isDeviceMotionOn = false
     var fastRegenerationSum : Double = 0
     var fastRegenerationArray : [Double] = []
     var medRegenerationSum : Double = 0
     var medRegenerationArray : [Double] = []
     var slowRegenerationSum : Double = 0
     var slowRegenerationArray : [Double] = []
     var inputUsrAcceleration : Double = 0
     var inputUsrAccelerationArray : [Double] = []
     var accYXArray : [Double] = []
     var accXArray : [Double] = []
     var gravityXArray : [Double] = []
     var gravityYArray : [Double] = []
     var gravityZArray : [Double] = []
     var accelerationZArray : [Double] = []
     var accelerationXArray : [Double] = []
     var activityFactorArray : [Double] = [0]
     var activityFactorArrayX : [Double] = [0]
     let motionManager = CMMotionManager()
     var currentNode = 0
     var acceleration : Double = 0
     var timeInterval : Double = 20
     var lastActivityCheat = false
     var gravX : Double = 0
     var gravY : Double = 0
     var gravZ : Double = 0
     var accY : Double = 0
     var accZ : Double = 0
     var accX : Double = 0
     var activityFactor : Double = 0
     var activityFactorX : Double = 0
     var temporaryTapDetection : Double?
     var tapCheatDetected = false
     let lowerLimit : Double = 0.25
     let upperLimit : Double = 1.4
     var sendToJumpFilter = false
     var sendToStampFilter = false
     var sendToSquatFilter = false
     var jumpIsClicked = false
     var stampIsClicked = false
     var squatIsClicked = false
     var firstLowValue = false
     var secondLowValue = false
     var firstHighValue = false
     var secondHighValue = false
     var jumpFilterCounter = 0
     var jumpFilterMemoryBool = false
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var acceptedOrNotView: UIView!
    @IBOutlet weak var leftBtnOutlet: UIButton!
    @IBOutlet weak var rightBtnOutlet: UIButton!
    @IBOutlet weak var stampOutlet: UIButton!
    @IBOutlet weak var jumpOutlet: UIButton!
    @IBOutlet weak var squatOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startButtonOutlet.layer.cornerRadius = 15
        clearButtonOutlet.layer.cornerRadius = 15
        acceptedOrNotView.layer.cornerRadius = acceptedOrNotView.frame.height / 2
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
     func updateGraph(){
        var inputLineEntry  = [ChartDataEntry]() //this is the Array that will be displayed on the graph.
        var medLineEntry  = [ChartDataEntry]()
        var slowLineEntry  = [ChartDataEntry]()
        var fastLineEntry  = [ChartDataEntry]()
        
        for i in 0..<inputUsrAccelerationArray.count {
            let inputValue = ChartDataEntry(x: Double(i), y: inputUsrAccelerationArray[i]) // here we set the X and Y status in a data chart
            let medValue = ChartDataEntry(x: Double(i), y: medRegenerationArray[i])
            let slowValue = ChartDataEntry(x: Double(i), y: slowRegenerationArray[i])
            let fastValue = ChartDataEntry(x: Double(i), y: fastRegenerationArray[i])
            
            inputLineEntry.append(inputValue) // here we add it to the data se
            medLineEntry.append(medValue)
            slowLineEntry.append(slowValue)
            fastLineEntry.append(fastValue)
        }
        
        let inputLine = LineChartDataSet(values: inputLineEntry, label: "InputAcceleration - XYZ") //Here we convert lineChartEntry to a LineChartDataSet
        inputLine.colors = [NSUIColor.blue] //Sets the colour to blue
        inputLine.circleRadius = 0
        
        let medLine = LineChartDataSet(values: medLineEntry, label: "Regen.Multiplier-Medium") //Here we convert lineChartEntry to a LineChartDataSet
        medLine.colors = [NSUIColor.green] //Sets the colorur to blue
        medLine.circleRadius = 0
        medLine.lineWidth = 3
        
        let slowLine = LineChartDataSet(values: slowLineEntry, label: "Regen.Multiplier-Slow") //Here we convert lineChartEntry to a LineChartDataSet
        slowLine.colors = [NSUIColor.purple] //Sets the colour to blue
        slowLine.circleRadius = 0
        slowLine.lineWidth = 3
        
        let fastLine = LineChartDataSet(values: fastLineEntry, label: "Regen.Multiplier-Fast") //Here we convert lineChartEntry to a LineChartDataSet
        fastLine.colors = [NSUIColor.darkGray] //Sets the colour to blue
        fastLine.circleRadius = 0
        fastLine.lineWidth = 3
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(inputLine) //Adds the line to the dataSet
        data.addDataSet(medLine)
        data.addDataSet(slowLine)
        data.addDataSet(fastLine)
        
        chtChart.data = data //it adds the chart data to the chart and causes an update
        currentNode += 1
        
        self.chtChart.setVisibleXRangeMinimum(200)
        self.chtChart.setVisibleXRangeMaximum(200)
        if sendToJumpFilter{
            self.chtChart.leftAxis.axisMinimum = -2
            self.chtChart.rightAxis.axisMinimum = -2
        }else{
            self.chtChart.leftAxis.axisMinimum = 0
            self.chtChart.rightAxis.axisMinimum = 0
        }
        self.chtChart.leftAxis.axisMaximum = 2
        self.chtChart.rightAxis.axisMaximum = 2
        
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
    }
    
    
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
    
     func calculateActivityFactorX(activityArrayX : Array<Double>) -> Double {
        
        // Calculate sum of array
        let activitySumX = activityArrayX.reduce(0) { $0 + $1 }
        
        // Get the speed of activity by dividing sum of values with nodes/.count
        let activityFactorX = activitySumX / Double(activityArrayX.count)
        
        return activityFactorX
    }
    
     func startAccelerometer(){
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                let x = abs(motion.userAcceleration.x)
                let y = abs(motion.userAcceleration.y)
                let z = abs(motion.userAcceleration.z)
                
                if self.inputUsrAccelerationArray.count > 200 {
                    self.inputUsrAccelerationArray.remove(at: 0)
                    self.medRegenerationArray.remove(at: 0)
                    self.slowRegenerationArray.remove(at: 0)
                    self.fastRegenerationArray.remove(at: 0)
                }
                //Detects Movement in all Chanels
                self.inputUsrAcceleration = x+y+z
                if self.sendToStampFilter{
                    self.inputUsrAccelerationArray.append(self.inputUsrAcceleration)
                }
                else if self.sendToJumpFilter{
                    self.inputUsrAccelerationArray.append(motion.userAcceleration.x)
                }
                else{
                    self.inputUsrAccelerationArray.append(self.inputUsrAcceleration)
                }
                
                self.acceleration = x+z
                self.medRegenerationArray.append(self.medRegenerationSum)
                self.slowRegenerationArray.append(self.slowRegenerationSum)
                self.fastRegenerationArray.append(self.fastRegenerationSum)
                self.updateGraph()
                
                let gravity = motion.gravity
                OperationQueue.main.addOperation {
                    if self.sendToStampFilter{
                        self.stampFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
                    }
                    else if self.sendToJumpFilter{
                        //Allow minus value of x to be sent through useracceleration.x
                        self.jumpFilter(gravity : gravity, accelerationX : motion.userAcceleration.x, motion : motion)
                    }
                    else{
                        self.stampFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
                    }
                    
                }
            }
        }
    }
    

     func UpdateRegenerationLine(activityFactor : Double){
        
        let maxActivity = 1.5
        
//        //Green Line
//        let additionFactorMedLine = (maxActivity - medRegenerationSum)/40
//        //Purple Line
//        let additionFactorSlowLine = (maxActivity - slowRegenerationSum)/80
//        //DarkGray
//        let additionFactorFastLine = (maxActivity - fastRegenerationSum)/15
//
        
            //Green Line
            let additionFactorMedLine = (maxActivity - medRegenerationSum)/40
            //Purple Line
            let additionFactorSlowLine = (maxActivity - slowRegenerationSum)/20
            //DarkGray
            let additionFactorFastLine = (maxActivity - fastRegenerationSum)/10
        
        if activityFactor == 0{
            if sendToStampFilter{
                slowRegenerationSum -= slowRegenerationSum*0.07
                medRegenerationSum -= medRegenerationSum*0.15
                fastRegenerationSum -= fastRegenerationSum*0.2
            }
            else if sendToJumpFilter{
                slowRegenerationSum -= slowRegenerationSum*0.03
                medRegenerationSum -= medRegenerationSum*0.06
                fastRegenerationSum -= fastRegenerationSum*0.09
            }
        }
        else{
            medRegenerationSum += abs(additionFactorMedLine)
            slowRegenerationSum += abs(additionFactorSlowLine)
            fastRegenerationSum += abs(additionFactorFastLine)
        }
        if medRegenerationSum <= 0{medRegenerationSum = 0}
        if slowRegenerationSum <= 0{slowRegenerationSum = 0}
        if fastRegenerationSum <= 0{fastRegenerationSum = 0}
        
        if medRegenerationSum > maxActivity{medRegenerationSum = maxActivity}
        if slowRegenerationSum > maxActivity{slowRegenerationSum = maxActivity}
        if fastRegenerationSum > maxActivity{fastRegenerationSum = maxActivity}
        
        print(medRegenerationSum)
        print(slowRegenerationSum)
        print(fastRegenerationSum)
    }
    
     func RedOrGreene(activityFactor : Double) {
        if activityFactor > lowerLimit && activityFactor < upperLimit{
            self.acceptedOrNotView.backgroundColor = .green
            
        }
        else{
            self.acceptedOrNotView.backgroundColor = .red
        }
    }
    
     func cheatingDetected(str : String){
        //print(str)
        self.lastActivityCheat = true
        self.acceptedOrNotView.backgroundColor = .red
    }
    
    @IBAction func longPressLeftBtn(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began{
            leftBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            leftBtnOutlet.tintColor = .black
        }
    }
    
    @IBAction func longPressRightBtn(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began{
            rightBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            rightBtnOutlet.tintColor = .black
        }
    }
    
    @IBAction func startBtn(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable{
            isDeviceMotionOn = !isDeviceMotionOn
            isDeviceMotionOn ? deviceMotionTurnOn() : deviceMotionTurnOff()
        }
    }
    
    @IBAction func stampBtn(_ sender: UIButton) {
        
        if stampIsClicked{
            setStampToFalse()
        }
        else{
            setStampToTrue()
            setJumpToFalse()
            setSquatToFalse()
        }
    }
    
    @IBAction func jumpBtn(_ sender: UIButton) {
        
        if jumpIsClicked{
            setJumpToFalse()
        }
        else{
            setJumpToTrue()
            setStampToFalse()
            setSquatToFalse()
        }
    }
    
    @IBAction func squatBtn(_ sender: UIButton) {
        
        if squatIsClicked{
            setSquatToFalse()
        }
        else{
            setSquatToTrue()
            setStampToFalse()
            setJumpToFalse()
        }
    }
    
    /*------------------------------------------------------------------------*/
    
     func setStampToFalse(){
        stampIsClicked = false
        stampOutlet.setTitleColor(.white, for: .normal)
        sendToStampFilter = false
    }
     func setStampToTrue(){
        stampIsClicked = true
        stampOutlet.setTitleColor(.gray, for: .normal)
        sendToStampFilter = true
    }
    
    
     func setJumpToFalse(){
        jumpIsClicked = false
        jumpOutlet.setTitleColor(.white, for: .normal)
        sendToJumpFilter = false
    }
    
     func setJumpToTrue(){
        jumpIsClicked = true
        jumpOutlet.setTitleColor(.gray, for: .normal)
        sendToJumpFilter = true
    }
    
     func setSquatToFalse(){
        squatIsClicked = false
        squatOutlet.setTitleColor(.white, for: .normal)
        sendToSquatFilter = false
    }
    
     func setSquatToTrue(){
        squatIsClicked = true
        squatOutlet.setTitleColor(.gray, for: .normal)
        sendToSquatFilter = true
    }
    
     func deviceMotionTurnOn(){
        startAccelerometer()
        buttonOutlet.setTitle("Stoppa", for: .normal)
    }
    
     func deviceMotionTurnOff(){
        motionManager.stopDeviceMotionUpdates()
        buttonOutlet.setTitle("Starta", for: .normal)
    }
    
    @IBAction func clearChartBtn(_ sender: UIButton) {
        if motionManager.isDeviceMotionAvailable{
            motionManager.stopDeviceMotionUpdates()
            resetAllValues()
            reloadInputViews()
            buttonOutlet.setTitle("Stoppa", for: .normal)
            motionManager.startDeviceMotionUpdates()
            startAccelerometer()
            isDeviceMotionOn = true
        }
        
    }
    
     func resetAllValues(){
        gravityXArray.removeAll()
        gravityYArray.removeAll()
        accelerationZArray.removeAll()
        inputUsrAccelerationArray.removeAll()
        accYXArray.removeAll()
        accXArray.removeAll()
        medRegenerationArray.removeAll()
        medRegenerationSum = 0
        slowRegenerationArray.removeAll()
        slowRegenerationSum = 0
        fastRegenerationArray.removeAll()
        fastRegenerationSum = 0
        currentNode = 0
    }
    
}
