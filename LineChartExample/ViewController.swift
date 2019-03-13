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
    
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
   
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
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        chtChart.data = data //finally - it adds the chart data to the chart and causes an update

//        self.lineChartView.setVisibleXRange(minXRange: CGFloat(1), maxXRange: CGFloat(50))
//        self.lineChartView.notifyDataSetChanged()
//        self.lineChartView.moveViewToX(CGFloat(i))
        
        self.chtChart.setVisibleXRangeMinimum(1)
        self.chtChart.setVisibleXRangeMaximum(5)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(point))
    
        point += 1
        
        chtChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph

    }

    func startAccelerometer(){
        
        motionManager.deviceMotionUpdateInterval = 0.3
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            if let motion = motion{
              
                var x = motion.userAcceleration.x
                var y = motion.userAcceleration.y
                var z = motion.userAcceleration.z
                
                x = round(100 * x) / 100
                y = round(100 * y) / 100
                z = round(100 * z) / 100
                print(z)
                if x.isZero && x.sign == .minus {
                    x = 0.0
                }
                
                if y.isZero && y.sign == .minus {
                    y = 0.0
                }
                
                if z.isZero && z.sign == .minus {
                    z = 0.0
                }
                
                self.numbers.append(z)
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
        on = false
        buttonOutlet.setTitle("Starta", for: .normal)
    }
    
    
    func startTimer(){
        
       accelerationCallTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startAccelerometer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        accelerationCallTimer.invalidate()
    }

}


