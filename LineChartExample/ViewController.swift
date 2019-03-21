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
    var numbers : [Double] = []
    var gravityXArray : [Double] = []
    var gravityYArray : [Double] = []
    var accelerationYArray : [Double] = []
    var accelerationZArray : [Double] = []
    var accelerationXArray : [Double] = []
    var inputAccYArray : [Double] = []
    var inputAccZArray : [Double] = []
    var inputAccXArray : [Double] = []
    var activityFactorArray : [Double] = [0]
    let motionManager = CMMotionManager()
    var currentNode = 0
    var acceleration : Double = 0
    var timeInterval : Double = 20
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
    
    func updateGraph(){
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        var lineChartEntry2  = [ChartDataEntry]()
        var lineChartEntry3  = [ChartDataEntry]()
        
        //The for loop
        for i in 0..<inputAccXArray.count {
            let value = ChartDataEntry(x: Double(i), y: inputAccXArray[i]) // here we set the X and Y status in a data chart
            let value2 = ChartDataEntry(x: Double(i), y: inputAccYArray[i])
            let value3 = ChartDataEntry(x: Double(i), y: inputAccZArray[i])
            lineChartEntry.append(value) // here we add it to the data se
            lineChartEntry2.append(value2)
            lineChartEntry3.append(value3)
            
        }
        let line1 = LineChartDataSet(values: lineChartEntry, label: "AccX") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.circleRadius = 0
        
        let line2 = LineChartDataSet(values: lineChartEntry2, label: "AccY") //Here we convert lineChartEntry to a LineChartDataSet
        line2.colors = [NSUIColor.yellow]
        line2.circleRadius = 0

        
        let line3 = LineChartDataSet(values: lineChartEntry3, label: "AccZ") //Here we convert lineChartEntry to a LineChartDataSet
        line3.colors = [NSUIColor.purple]
        line3.circleRadius = 0
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        data.addDataSet(line2)
        data.addDataSet(line3)
        
        chtChart.data = data //it adds the chart data to the chart and causes an update
        currentNode += 1
        self.chtChart.setVisibleXRangeMinimum(200)
        self.chtChart.setVisibleXRangeMaximum(200)
        self.chtChart.leftAxis.axisMinimum = 0
        self.chtChart.rightAxis.axisMinimum = 0
        self.chtChart.leftAxis.axisMaximum = 2.0
        self.chtChart.rightAxis.axisMaximum = 2.0

        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
        
        lineChartEntry.removeAll()
        lineChartEntry2.removeAll()
        lineChartEntry3.removeAll()
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
    
    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                let x = abs(motion.userAcceleration.x)
                let y = abs(motion.userAcceleration.y)
                let z = abs(motion.userAcceleration.z)
                self.inputAccXArray.append(x)
                self.inputAccYArray.append(y)
                self.inputAccZArray.append(z)
    
                if self.inputAccXArray.count > 200 {
                    self.inputAccYArray.remove(at: 0)
                    self.inputAccXArray.remove(at: 0)
                    self.inputAccZArray.remove(at: 0)
                }
                //Detects Movement in all Chanels
                self.acceleration = round((x+z) * 100) / 100
                
                self.updateGraph()
               
//                let gravity = motion.gravity
//                OperationQueue.main.addOperation {
//                    self.cheatingFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
//
//                }
            }
        }
    }
    
//    func cheatingFilter(gravity : CMAcceleration, acceleration : Double, motion : CMDeviceMotion){
//
//        //When hit hard, not normal behaviour
//        if numbers.count < 20{
//            gravityXArray.append(abs(gravity.x))
//            gravityYArray.append(abs(gravity.y))
//            accelerationZArray.append(abs(motion.userAcceleration.z))
//            accelerationXArray.append(abs(motion.userAcceleration.x))
//            self.numbers.append(acceleration)
//        }
//        else{
//            gravX = calculateActivityFactor(activityArray: gravityXArray)
//            gravY = calculateActivityFactor(activityArray: gravityYArray)
//            accX = calculateActivityFactor(activityArray: accelerationXArray)
//            accZ = calculateActivityFactor(activityArray: accelerationZArray)
//            activityFactor = calculateActivityFactor(activityArray: numbers)
//            if activityFactor > 0.25 {
//                 print("ActivityFactor \(activityFactor)")
//            }
//            activityFactorArray.append(activityFactor)
//
//            if let temporaryTapDetection = temporaryTapDetection {
//                if temporaryTapDetection > activityFactor + 0.3 || temporaryTapDetection < activityFactor - 0.3{
//                    print("Tap Cheat Detection")
//                    tapCheatDetected = true
//                }
//                else{
//                    tapCheatDetected = false
//                }
//            }
//            temporaryTapDetection = activityFactor
//
//            if self.gravX > 0.5 && gravY < 0.25 && accZ < 0.65 && accY < 0.6 && self.activityFactor > 0.25 && self.activityFactor < 1.4 && tapCheatDetected == false && leftBtnOutlet.tintColor == .green && rightBtnOutlet.tintColor == .green{
//               // print("Godkänt")
//                self.acceptedOrNotView.backgroundColor = .green
//            }
//            else{
//                cheatingDetected(str : "Fusk")
//            }
//
//            // 5 times a second
//
//            self.numbers.removeAll()
//            self.gravityXArray.removeAll()
//            self.gravityYArray.removeAll()
////            self.accelerationYArray.removeAll()
////            self.accelerationZArray.removeAll()
//            //Set tap detection to previous value
//
//            gravX = 0
//            gravY = 0
//            accY = 0
//            accZ = 0
//        }
//
//    }
    
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
        
    sender.minimumPressDuration = 0.01
        if sender.state == .began{
         //   print("Vänster Godkänd")
            leftBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            leftBtnOutlet.tintColor = .black
        }
    }
    
    @IBAction func longPressRightBtn(_ sender: UILongPressGestureRecognizer) {
        sender.minimumPressDuration = 0.01
        if sender.state == .began{
            //print("Höger Godkänd")
            rightBtnOutlet.tintColor = .green
        }
        if sender.state == .ended{
            rightBtnOutlet.tintColor = .black
        }
    }
    
    @IBAction func startBtn(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable{
            if isDeviceMotionOn == false{
                isDeviceMotionOn = true
                startAccelerometer()
                buttonOutlet.setTitle("Stoppa", for: .normal)
            }
            else{
                isDeviceMotionOn = false
                motionManager.stopDeviceMotionUpdates()
                buttonOutlet.setTitle("Starta", for: .normal)
            }
        }
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
        numbers.removeAll()
        activityFactorArray.removeAll()
        self.gravityXArray.removeAll()
        self.gravityYArray.removeAll()
        self.accelerationYArray.removeAll()
        self.accelerationZArray.removeAll()
        self.inputAccYArray.removeAll()
        self.inputAccXArray.removeAll()
        self.inputAccZArray.removeAll()
        currentNode = 0
    }
    
}
