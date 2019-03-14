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
    let motionManager = CMMotionManager()
    var currentNode = 0
    var maxValue : Double = 0
    var minValue : Double = 0
    var sumCloseToMaxPoints : Double = 0
    var sumCloseToMinPoints : Double = 0
    //var allNodes = 1
    var closeToMaxNodes = 0
    var closeToMinNodes = 0
    var averageCloseToMax : Double = 0
    var averageCloseToMin : Double = 0
    var acceleration : Double = 0
    
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
        //here is the for loop
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart
            lineChartEntry.append(value) // here we add it to the data set
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        line1.circleRadius = 2
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        chtChart.data = data //finally - it adds the chart data to the chart and causes an update
        
        self.chtChart.setVisibleXRangeMinimum(1)
        self.chtChart.setVisibleXRangeMaximum(200)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
       
        
        
        // Lägg till värdena i en ny array
        batchNumbersArray.append(numbers[currentNode])
        
        // Antal nodes (points) i grafen
        currentNode += 1
        //print(currentNode)
        // vid var 20 Node:
        if currentNode % 20 == 0 {
            //print(batchNumbersArray)
            calculateActivityFactor(currentNode: currentNode, activityArray: batchNumbersArray)
            // kalla på funktion; (räkna ihop alla värden, medelvärdet (hastighet))
            
            // Töm arrayen
            batchNumbersArray.removeAll()
            
        }
        
        
        
        chtChart.chartDescription?.text = "Seismograph" // Here we set the description for the graph
        
    }
    
    func calculateActivityFactor(currentNode : Int, activityArray : Array<Double>) {
        
        // Räkna ihop alla värden i arrayen, dividera med antal nodes -> medelvärdet (hastighet)
            let activitySum = activityArray.reduce(0) { $0 + $1 }
        
            let activityFactor = activitySum / Double(currentNode)
        print("ActivityFactor: \(activityFactor)")
        //var activitySpeed =
    }
    
    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/20 //How many nodes per second?
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
                
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                //All positive numbers
                x = abs(round(100 * x) / 100)
                y = abs(round(100 * y) / 100)
                z = abs(round(100 * z) / 100)
        
               
                self.acceleration = x+y+z
                
                
                if self.acceleration > self.maxValue{
                    self.maxValue = self.acceleration
                    self.maxValue = round(self.maxValue * 100) / 100
                    //print("MAXVALUE = \(self.maxValue)")
                    self.maxValueLabel.text = "Max: " + String(self.maxValue)
                }
                
                if self.maxValue > 0.3 && (z + 0.5) > self.maxValue{
                    self.closeToMaxNodes += 1
                    self.sumCloseToMaxPoints += Double(z)
                    
                    self.averageCloseToMax = self.sumCloseToMaxPoints/Double(self.closeToMaxNodes)
                    
                    self.averageCloseToMax = round(self.averageCloseToMax * 100) / 100
                    self.averageLabel.text = "Medel: " + String(self.averageCloseToMax) + "\n" + String(self.averageCloseToMin)
                    //print("MEDELVÄRDE" + String(self.averageCloseToMax))
                }
                
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
            reloadInputViews()
            maxValue = 0
            minValue = 0
            averageCloseToMax = 0
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
