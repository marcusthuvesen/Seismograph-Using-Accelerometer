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
    private var isDeviceMotionOn = false
    private var fastRegenerationSum : Double = 0
    private var fastRegenerationArray : [Double] = []
    private var medRegenerationSum : Double = 0
    private var medRegenerationArray : [Double] = []
    private var slowRegenerationSum : Double = 0
    private var slowRegenerationArray : [Double] = []
    private var inputUsrAcceleration : Double = 0
    private var inputUsrAccelerationArray : [Double] = []
    private var accZXArray : [Double] = []
    private var gravityXArray : [Double] = []
    private var gravityYArray : [Double] = []
    private var accelerationZArray : [Double] = []
    private var accelerationXArray : [Double] = []
    private var activityFactorArray : [Double] = [0]
    private let motionManager = CMMotionManager()
    private var currentNode = 0
    private var acceleration : Double = 0
    private var timeInterval : Double = 50
    private var lastActivityCheat = false
    private var gravX : Double = 0
    private var gravY : Double = 0
    private var accY : Double = 0
    private var accZ : Double = 0
    private var accX : Double = 0
    private var activityFactor : Double = 0
    private var temporaryTapDetection : Double?
    private var tapCheatDetected = false
    private let lowerLimit : Double = 0.25
    private let upperLimit : Double = 1.4
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var acceptedOrNotView: UIView!
    @IBOutlet weak var leftBtnOutlet: UIButton!
    @IBOutlet weak var rightBtnOutlet: UIButton!
    
    
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
    
    private func updateGraph(){
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
        
        self.chtChart.setVisibleXRangeMinimum(400)
        self.chtChart.setVisibleXRangeMaximum(400)
        self.chtChart.leftAxis.axisMinimum = 0
        self.chtChart.rightAxis.axisMinimum = 0
        self.chtChart.leftAxis.axisMaximum = 2
        self.chtChart.rightAxis.axisMaximum = 2
        
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
    }
    
    // Function for users speed
    private func calculateActivityFactor(activityArray : Array<Double>) -> Double {
        
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
    
    private func startAccelerometer(){
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                let x = abs(motion.userAcceleration.x)
                let y = abs(motion.userAcceleration.y)
                let z = abs(motion.userAcceleration.z)
                
                if self.inputUsrAccelerationArray.count > 400 {
                    self.inputUsrAccelerationArray.remove(at: 0)
                    self.medRegenerationArray.remove(at: 0)
                    self.slowRegenerationArray.remove(at: 0)
                    self.fastRegenerationArray.remove(at: 0)
                }
                //Detects Movement in all Chanels
                self.inputUsrAcceleration = x+y+z
                self.inputUsrAccelerationArray.append(self.inputUsrAcceleration)
                self.acceleration = x+z
                self.medRegenerationArray.append(self.medRegenerationSum)
                self.slowRegenerationArray.append(self.slowRegenerationSum)
                self.fastRegenerationArray.append(self.fastRegenerationSum)
                self.updateGraph()
                
                let gravity = motion.gravity
                OperationQueue.main.addOperation {
                    self.cheatingFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
                }
            }
        }
    }
    
    private func cheatingFilter(gravity : CMAcceleration, acceleration : Double, motion : CMDeviceMotion){
        
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
            //print("ActivityFactor \(activityFactor)")
            
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
            
            if self.gravX > 0.9 && gravY < 0.25 && gravity.z < 0 && accZ < 0.5 && accY < 0.6 && activityFactor > 0.25 && activityFactor < 1.4 && tapCheatDetected == false && leftBtnOutlet.tintColor == .green && rightBtnOutlet.tintColor == .green{
                //Accepted
                self.acceptedOrNotView.backgroundColor = .green
                UpdateRegenerationLine(activityFactor: activityFactor)
            }
            else{
                UpdateRegenerationLine(activityFactor: 0)
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
    
    private func UpdateRegenerationLine(activityFactor : Double){
        
        let maxActivity = 1.5
        
        //Green Line
        let additionFactorMedLine = (maxActivity - medRegenerationSum)/5 //40
        //Purple Line
        let additionFactorSlowLine = (maxActivity - slowRegenerationSum)/5 //80
        //DarkGray
        let additionFactorFastLine = (maxActivity - fastRegenerationSum)/5//15
        if activityFactor == 0{

        slowRegenerationSum -= slowRegenerationSum*0.3
        medRegenerationSum -= medRegenerationSum*0.2
        fastRegenerationSum -= fastRegenerationSum*0.1

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
    }
    
    private func RedOrGreene(activityFactor : Double) {
        if activityFactor > lowerLimit && activityFactor < upperLimit{
            self.acceptedOrNotView.backgroundColor = .green
            
        }
        else{
            self.acceptedOrNotView.backgroundColor = .red
        }
    }
    
    private func cheatingDetected(str : String){
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
    
    private func deviceMotionTurnOn(){
        startAccelerometer()
        buttonOutlet.setTitle("Stoppa", for: .normal)
    }
    
    private func deviceMotionTurnOff(){
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
    
    private func resetAllValues(){
        gravityXArray.removeAll()
        gravityYArray.removeAll()
        accelerationZArray.removeAll()
        inputUsrAccelerationArray.removeAll()
        accZXArray.removeAll()
        medRegenerationArray.removeAll()
        medRegenerationSum = 0
        slowRegenerationArray.removeAll()
        slowRegenerationSum = 0
        fastRegenerationArray.removeAll()
        fastRegenerationSum = 0
        currentNode = 0
    }
    
}
