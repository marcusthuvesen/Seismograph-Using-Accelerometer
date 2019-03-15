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
    var timeInterval : Double = 20
    var batchNumbersArray = [Double]()
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startButtonOutlet.layer.cornerRadius = 15
        clearButtonOutlet.layer.cornerRadius = 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateGraph(){
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        var averageChartLine = [ChartDataEntry]()
        //here is the for loop
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart
            let value2 = ChartDataEntry(x: Double(i), y: averageArray[i])
            lineChartEntry.append(value) // here we add it to the data set
            averageChartLine.append(value2)
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Current Activity") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.circleRadius = 0
        
        let line2 = LineChartDataSet(values: averageChartLine, label: "Average")
        line2.colors = [NSUIColor.red] //Sets the colour to blue
        line2.circleRadius = 0
        
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        data.addDataSet(line2)
        chtChart.data = data //it adds the chart data to the chart and causes an update
        
        self.chtChart.setVisibleXRangeMinimum(1)
        self.chtChart.setVisibleXRangeMaximum(200)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))

        
        // Add Values to Array
        batchNumbersArray.append(numbers[currentNode])
        
        // The Latest Node Number
        currentNode += 1
        
        // Every Second
        if currentNode % Int(timeInterval) == 0 {
            //print(batchNumbersArray)
            calculateActivityFactor(activityArray: batchNumbersArray)
            // kalla på funktion; (räkna ihop alla värden, medelvärdet (hastighet))
            
            // Töm arrayen
            batchNumbersArray.removeAll()
            
        }
        
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
        
    }
    
    // Function for users speed
    func calculateActivityFactor(activityArray : Array<Double>) {
        
        // Calculate sum of array
        let activitySum = activityArray.reduce(0) { $0 + $1 }
        
        // Get the speed of activity by dividing sum of values with nodes/.count
        let activityFactor = activitySum / Double(activityArray.count)

        print("ActivityFactor: \(activityFactor)")
    }
    
    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                //All positive numbers
                x = abs(round(100 * x) / 100)
                y = abs(round(100 * y) / 100)
                z = abs(round(100 * z) / 100)
        
               //Detects Movement in all Chanels
                self.acceleration = x+y+z
                
                
                if self.acceleration > self.maxValue{
                    self.maxValue = self.acceleration
                    self.maxValue = round(self.maxValue * 100) / 100
                    
                    self.maxValueLabel.text = "Max: " + String(self.maxValue)
                }
                
                if self.acceleration > 0.4 {
                    self.averageNodes += 1
                    self.sumAverageNodes += Double(self.acceleration)
                    
                    self.averageValue = self.sumAverageNodes/Double(self.averageNodes)
                    
                    self.averageValue = round(self.averageValue * 100) / 100
                    self.temporaryAverage = self.averageValue
                    self.averageLabel.text = "Medel: " + String(self.averageValue)
                    
                }
                else{
                    self.averageValue = self.temporaryAverage
                }
                print(self.averageArray)
                self.averageArray.append(self.averageValue)
                self.numbers.append(self.acceleration)
                self.updateGraph()
                
            }
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
            numbers.removeAll()
            averageArray.removeAll()
            averageValue = 0
            sumAverageNodes = 0
            averageNodes = 0
            temporaryAverage = 0
            reloadInputViews()
            maxValue = 0
            minValue = 0
            averageValue = 0
            averageCloseToMin = 0
            currentNode = 0
            minValueLabel.text = "0"
            maxValueLabel.text = "0"
            averageLabel.text = "0"
            buttonOutlet.setTitle("Stoppa", for: .normal)
            motionManager.startDeviceMotionUpdates()
            startAccelerometer()
            isDeviceMotionOn = true
        }

    }
    
}
