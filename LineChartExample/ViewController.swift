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
    var limitUpperArray : [Double] = [1.7]
    var limitLowerArray : [Double] = [0.35]
    var activityFactorArray : [Double] = [0]
    let motionManager = CMMotionManager()
    var currentNode = 0
    var maxValue : Double = 0
    var minValue : Double = 0
    var averageValue : Double = 0
    var acceleration : Double = 0
    var timeInterval : Double = 100
    var batchNumbersArray = [Double]()
    var lastActivityCheat = false
    var gravX : Double = 0
    var gravY : Double = 0
    var accY : Double = 0
    var accZ : Double = 0
    var activityFactor : Double = 0
    
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
        var lineChartEntry2  = [ChartDataEntry]()
        var lineChartEntry3  = [ChartDataEntry]()
        
        //The for loop
        for i in 0..<activityFactorArray.count {
            let value = ChartDataEntry(x: Double(i), y: activityFactorArray[i]) // here we set the X and Y status in a data chart
            let value2 = ChartDataEntry(x: Double(i), y: limitLowerArray[0])
            let value3 = ChartDataEntry(x: Double(i), y: limitUpperArray[0])
            lineChartEntry.append(value) // here we add it to the data se
            lineChartEntry2.append(value2)
            lineChartEntry3.append(value3)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Activity Factor") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.circleRadius = 0
        line1.fillColor = .black
        line1.drawFilledEnabled = true
        
        let line2 = LineChartDataSet(values: lineChartEntry2, label: "Undre Gräns") //Here we convert lineChartEntry to a LineChartDataSet
        line2.colors = [NSUIColor.red]
        line2.circleRadius = 0
        line2.fillColor = .red
        line2.drawFilledEnabled = true
        
        let line3 = LineChartDataSet(values: lineChartEntry3, label: "Övre Gräns") //Here we convert lineChartEntry to a LineChartDataSet
        line3.colors = [NSUIColor.red]
        line3.circleRadius = 0
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        data.addDataSet(line2)
        data.addDataSet(line3)
        
        chtChart.data = data //it adds the chart data to the chart and causes an update
        currentNode += 1
        self.chtChart.setVisibleXRangeMinimum(250)
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
        if activityFactor > 0.25{
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
                //Detects Movement in all Chanels
                self.acceleration = round((x+y+z) * 100) / 100
                
                if self.acceleration > self.maxValue{
                    self.maxValue = self.acceleration
                    self.maxValue = round(self.maxValue * 100) / 100
                    
                    self.maxValueLabel.text = "Max: " + String(self.maxValue)
                }
                
                
                //Filtering for wrong direction of useracceleration
                let gravity = motion.gravity
                OperationQueue.main.addOperation {
                    self.cheatingFilter(gravity : gravity, acceleration : self.acceleration, motion : motion)
                    
                }
            }
        }
    }
    
    func cheatingFilter(gravity : CMAcceleration, acceleration : Double, motion : CMDeviceMotion){
        
        //When hit hard, not normal behaviour
        if numbers.count < 20{
            gravityXArray.append(abs(gravity.x))
            gravityYArray.append(abs(gravity.y))
            accelerationYArray.append(abs(motion.userAcceleration.y))
            accelerationZArray.append(abs(motion.userAcceleration.z))
            self.numbers.append(acceleration)
        }
        else{
            gravX = calculateActivityFactor(activityArray: gravityXArray)
            gravY = calculateActivityFactor(activityArray: gravityYArray)
            accY = calculateActivityFactor(activityArray: accelerationYArray)
            accZ = calculateActivityFactor(activityArray: accelerationZArray)
            activityFactor = calculateActivityFactor(activityArray: numbers)
            print("ActivityFactor \(activityFactor)")
            activityFactorArray.append(activityFactor)
            
            if self.gravX > 0.5 && gravY < 0.25 && accZ < 0.65 && accY < 0.6 && self.activityFactor > 0.35 && self.activityFactor < 1.7{
                print("Godkänt")
                self.acceptedOrNotView.backgroundColor = .green
            }
            else{
                cheatingDetected(str : "Fusk")
            }
            
            // 5 times a second
           
            self.updateGraph()
            self.numbers.removeAll()
            self.gravityXArray.removeAll()
            self.gravityYArray.removeAll()
            self.accelerationYArray.removeAll()
            self.accelerationZArray.removeAll()
            gravX = 0
            gravY = 0
            accY = 0
            accZ = 0
        }
     
    }
    
    func RedOrGreene(activityFactor : Double) {
        if activityFactor > 0.35 && activityFactor < 1.7{
            self.acceptedOrNotView.backgroundColor = .green
            
        }
        else{
            self.acceptedOrNotView.backgroundColor = .red
        }
    }
    
    func cheatingDetected(str : String){
        print(str)
        self.lastActivityCheat = true
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
        self.gravityXArray.removeAll()
        self.gravityYArray.removeAll()
        self.accelerationYArray.removeAll()
        self.accelerationZArray.removeAll()
        maxValue = 0
        minValue = 0
        currentNode = 0
        minValueLabel.text = "0"
        maxValueLabel.text = "0"
        averageLabel.text = "0"
    }
    
}
