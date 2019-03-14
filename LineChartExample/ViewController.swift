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
    var on = false
    var numbers : [Double] = []
    var accelerationCallTimer = Timer()
    let motionManager = CMMotionManager()
    var point = 0
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

//        self.lineChartView.setVisibleXRange(minXRange: CGFloat(1), maxXRange: CGFloat(50))
//        self.lineChartView.notifyDataSetChanged()
//        self.lineChartView.moveViewToX(CGFloat(i))
        
        self.chtChart.setVisibleXRangeMinimum(1)
        self.chtChart.setVisibleXRangeMaximum(200)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(point))
    
        
        point += 1
        
        chtChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph

    }

    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 1/20
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
              
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                
                x = round(100 * x) / 100
                y = round(100 * y) / 100
                z = round(100 * z) / 100
                //print(z)
                if x < 0 {
                    x = abs(x)
                }
                
                if y < 0 {
                   y = abs(y)
                }
                
                if z < 0 {
                    z = abs(z)
                }
                
                self.acceleration = x+y+z
                
                
                if self.acceleration > self.maxValue{
                    self.maxValue = self.acceleration
                    //print("MAXVALUE = \(self.maxValue)")
                    self.maxValueLabel.text = "Max: " + String(self.maxValue)
                }
              /*  if z < self.minValue{
                    self.minValue =
                    //print("MINVALUE = \(self.minValue)")
                    self.minValueLabel.text = "Min: " + String(self.minValue)
                }*/
                //Average Close To Max
                
                if self.maxValue > 0.3 && (z + 0.5) > self.maxValue{
                     self.closeToMaxNodes += 1
                     self.sumCloseToMaxPoints += Double(z)
                    
                     self.averageCloseToMax = self.sumCloseToMaxPoints/Double(self.closeToMaxNodes)
                    
                     self.averageCloseToMax = round(self.averageCloseToMax * 100) / 100
                     self.averageLabel.text = "Medel: " + String(self.averageCloseToMax) + "\n" + String(self.averageCloseToMin)
                     print("MEDELVÄRDE" + String(self.averageCloseToMax))
                }
                
                //Average Close To Min
                
               /* if self.minValue < -0.3 && (z - 0.5) < self.minValue{
                    self.closeToMinNodes += 1
                    self.sumCloseToMinPoints += Double(z)
                    
                    self.averageCloseToMin = self.sumCloseToMinPoints/Double(self.closeToMinNodes)
                    
                    self.averageCloseToMin = round(self.averageCloseToMin * 100) / 100
                    self.averageLabel.text = "Medel: " + String(self.averageCloseToMax) + "\n" + String(self.averageCloseToMin)
                    print("MEDELVÄRDE" + String(self.averageCloseToMax) + "\n" + String(self.averageCloseToMin))
                }*/
                
               
               
                self.numbers.append(self.acceleration)
                self.updateGraph()
                
            }
        }
        
    }
    
    @IBAction func btnbutton(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable{
            if on == false{
                startTimer()
                on = true
                buttonOutlet.setTitle("Stoppa", for: .normal)
            }
            else{
                on = false
                motionManager.stopDeviceMotionUpdates()
                stopTimer()
                buttonOutlet.setTitle("Starta", for: .normal)
            }
        }
    }
    
    @IBAction func clearChart(_ sender: UIButton) {
        stopTimer()
        motionManager.stopDeviceMotionUpdates()
        numbers.removeAll()
        reloadInputViews()
        startTimer()
        on = true
        buttonOutlet.setTitle("Stoppa", for: .normal)
        maxValue = 0
        minValue = 0
        averageCloseToMax = 0
        averageCloseToMin = 0
        minValueLabel.text = "0"
        maxValueLabel.text = "0"
        averageLabel.text = "0"
        
    }
    
    
    func startTimer(){
        
       accelerationCallTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startAccelerometer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        accelerationCallTimer.invalidate()
    }

}


