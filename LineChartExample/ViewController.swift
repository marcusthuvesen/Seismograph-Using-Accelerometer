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
    var averageArray : [Double] = [0]
    var activityFactorArray : [Double] = [0]
    let motionManager = CMMotionManager()
    var currentNode = 0
    var maxValue : Double = 0
    var minValue : Double = 0
    var sumAverageNodes : Double = 0
    var sumCloseToMinPoints : Double = 0
    var temporaryAverage : Double = 0
    var averageNodes = 0
    var closeToMinNodes = 0
    var averageValue : Double = 0
    var averageCloseToMin : Double = 0
    var acceleration : Double = 0
    var timeInterval : Double = 100
    var batchNumbersArray = [Double]()
    var lastActivityCheat = false
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var acceptedOrNotView: UIView!
    
    
    
    
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
        //        var averageChartLine = [ChartDataEntry]()
        //        var activityFactorLine = [ChartDataEntry]()
        
        let activityFactor = calculateActivityFactor(activityArray: numbers)
        activityFilter(activityFactor : activityFactor)
        activityFactorArray.append(activityFactor)
        print("ActivityFactor \(activityFactor)")
        // Töm arrayen
        //batchNumbersArray.removeAll()
        
        
        //here is the for loop
        for i in 0..<activityFactorArray.count {
            let value = ChartDataEntry(x: Double(i), y: activityFactorArray[i]) // here we set the X and Y status in a data chart
            
            lineChartEntry.append(value) // here we add it to the data se
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Current Activity") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.circleRadius = 0
        
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        chtChart.data = data //it adds the chart data to the chart and causes an update
        currentNode += 1
        self.chtChart.setVisibleXRangeMinimum(1)
        self.chtChart.setVisibleXRangeMaximum(250)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
        
    }
    
    // Function for users speed
    func calculateActivityFactor(activityArray : Array<Double>) -> Double {
        
        // Calculate sum of array
        let activitySum = activityArray.reduce(0) { $0 + $1 }
        
        // Get the speed of activity by dividing sum of values with nodes/.count
        let activityFactor = activitySum / Double(activityArray.count)
        if activityFactor > 0.3{
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
                
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                //All positive numbers
                x = abs(x)
                y = abs(y)
                z = abs(z)
                
                //Detects Movement in all Chanels
                self.acceleration = round((x+y+z) * 100) / 100
                
                
                
                if self.acceleration > self.maxValue{
                    self.maxValue = self.acceleration
                    self.maxValue = round(self.maxValue * 100) / 100
                    
                    self.maxValueLabel.text = "Max: " + String(self.maxValue)
                }
                
                let gravity = motion.gravity
                cheatingFilter(acceleration : acceleration, motion : motion, gravity : gravity)
                
                //When hit hard, not normal behaviour
                if self.acceleration > 1.9{
                    print("Aktivitet ÖVER TVÅ")
                    self.lastActivityCheat = true
                }
                //Filtering for wrong direction of useracceleration
                
                OperationQueue.main.addOperation {
                    
                    //IF CHEATING
                    if abs(gravity.z) > 0.87 && (abs(motion.userAcceleration.x) > 0.6 || abs(motion.userAcceleration.y) > 0.6) {
                        self.cheatingDetected(str : "FUSK1")
                        
                    }
                        
                    else if abs(gravity.x) > 0.5 && (abs(motion.userAcceleration.z) > 0.6 || abs(motion.userAcceleration.y) > 0.6) {
                        self.cheatingDetected(str : "FUSK2")
                        
                    }
                        
                    else if abs(gravity.y) > 0.5 && (abs(motion.userAcceleration.x) > 0.6 || abs(motion.userAcceleration.z) > 0.6) {
                        self.cheatingDetected(str : "FUSK3")
                    }
                        
                    else{
                        //If Last activity was cheat this activityfactor won't be guilty either
                        if self.lastActivityCheat == true{
                            self.lastActivityCheat = false
                        }
                         //Activity passes as Accepted
                        else{
                            self.lastActivityCheat = false
                            self.numbers.append(self.acceleration)
                            // Every Second
                            if self.numbers.count % Int(20) == 0 {
                                self.updateGraph()
                                self.numbers.removeAll()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func cheatingFilter(){
        
    }
    
    
    
    func activityFilter(activityFactor : Double) {
        if activityFactor > 0.5 && activityFactor < 1.7{
            self.acceptedOrNotView.backgroundColor = .green
        }
        else{
            self.acceptedOrNotView.backgroundColor = .red
        }
    }
    
    func cheatingDetected(str : String){
        print(str)
        self.acceptedOrNotView.backgroundColor = .red
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
        maxValue = 0
        minValue = 0
        currentNode = 0
        minValueLabel.text = "0"
        maxValueLabel.text = "0"
        averageLabel.text = "0"
    }
    
}
