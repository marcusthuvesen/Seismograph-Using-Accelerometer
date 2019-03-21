//
//  FourAxisAbsViewController.swift
//  LineChartExample
//
//  Created by Henrik Jangefelt on 2019-03-20.
//  Copyright © 2019 Osian. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class FourAxisAbsViewController: UIViewController {

    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var minValueLabel: UILabel!
    @IBOutlet weak var maxValueLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var validStepsIndicator: UIView!
    
    var timeInterval : Double = 20
    let motionManager = CMMotionManager()
    var acceleration = 0.0
    var maxValue = 0.0
    var minValue = 0.0
    var isDeviceMotionOn = false
    var currentNode = 0
    var userActivitySpeed = [Double]() // användarens "medelhastighet"

    var xValueArray = [Double]()
    var yValueArray = [Double]()
    var zValueArray = [Double]()
    var accelerationArray = [Double]()
    var tempArray = [Double]()
    
    // Array för att spara värden till användarens medelhastighet
    var activityFactorArray = [Double]()
    var activityValueArray = [Double]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func updateGraph() {
        
        var xLineChartEntry = [ChartDataEntry]() // X värdet
        var yLineChartEntry = [ChartDataEntry]() // Y värdet
        var zLineChartEntry = [ChartDataEntry]()
        var activityChartEntry = [ChartDataEntry]() // Användarens medelhastighet
        
        // numbers.count gemensam array för alla axlarna
        for i in 0..<accelerationArray.count {
            
            let xValue = ChartDataEntry(x: Double(i), y: xValueArray[i])
            let yValue = ChartDataEntry(x: Double(i), y: yValueArray[i])
            let zValue = ChartDataEntry(x: Double(i), y: zValueArray[i])
            
            xLineChartEntry.append(xValue)
            yLineChartEntry.append(yValue)
            zLineChartEntry.append(zValue)
        }
        
        // Array för
        for i in 0..<activityFactorArray.count {
            
            let activityValue = ChartDataEntry(x: Double(i), y: activityValueArray[i])
            activityChartEntry.append(activityValue)
        }
        
        let lineX = LineChartDataSet(values: xLineChartEntry, label: "user Acceleration X")
        lineX.colors = [NSUIColor.blue]
        lineX.circleRadius = 0
        
        let lineY = LineChartDataSet(values: yLineChartEntry, label: "user Acceleration Y")
        lineY.colors = [NSUIColor.red]
        lineY.circleRadius = 0
        
        let lineZ = LineChartDataSet(values: zLineChartEntry, label: "user Acceleration Z")
        lineZ.colors = [NSUIColor.gray]
        lineZ.circleRadius = 0
        
        let lineActivity = LineChartDataSet(values: activityChartEntry, label: "user Activity")
        lineActivity.colors = [NSUIColor.black]
        lineActivity.circleRadius = 0
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(lineX) //Adds the line to the dataSet
        data.addDataSet(lineY)
        data.addDataSet(lineZ)
        data.addDataSet(lineActivity)
        chtChart.data = data //it adds the chart data to the chart and causes an update
        
        self.chtChart.setVisibleXRangeMinimum(250)
        self.chtChart.setVisibleXRangeMaximum(250)
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        
        
        tempArray.append(accelerationArray[currentNode])
        currentNode += 1
        
        
        
        // Every Second
        if currentNode % 5 == 0 {
            
            
            
            // kalla på funktion; (räkna ihop alla värden, medelvärdet (hastighet))
            let averageX = calculateAverageSpeed(myArray: xValueArray)
            let averageY = calculateAverageSpeed(myArray: yValueArray)
            let averageZ = calculateAverageSpeed(myArray: zValueArray)
            let averageActivity = calculateAverageSpeed(myArray: tempArray) // TEST??
            activityValueArray.append(averageActivity)

            
            print("average X: \(averageX)")
            print("average Y: \(averageY)")
            
            // Töm arrayen
            tempArray.removeAll()
        }
    }
    
   
    
    
    func startDeviceMotion() {
        
        motionManager.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
        motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
            
            
            guard let motion = motion else {
                return
            }
            
            var userAccelerationX = abs(motion.userAcceleration.x)
            var userAccelerationY = abs(motion.userAcceleration.y)
            var userAccelerationZ = abs(motion.userAcceleration.z)

            var gravity = motion.gravity
            
            
            
            
            
            //if abs(gravity.x) > abs() && abs(gravity.z) > abs(gravity.y) {
            if abs(gravity.x) > abs(gravity.y) && abs(gravity.z) > abs(gravity.y) {
                
                if abs(userAccelerationX) > 0.35 && abs(userAccelerationX) > abs(userAccelerationZ) && abs(userAccelerationZ) > abs(userAccelerationY) {
                    
                    
                    self.validStepsIndicator.backgroundColor = .green
                    
                    
                } else {
                    self.validStepsIndicator.backgroundColor = .red
                }
            } else {
                self.validStepsIndicator.backgroundColor = .red
            }
            
            
            // TEST UTAN userAcceleration i Z-led (kanske testa, x + z)
            //let userAccel = userAccelerationX + userAccelerationZ
            
            let userAccelerationXYZ = round((userAccelerationX + userAccelerationY + userAccelerationZ) * 100) / 100
            
            
            self.accelerationArray.append(userAccelerationXYZ)
            self.xValueArray.append(userAccelerationX)
            self.yValueArray.append(userAccelerationY)
            self.zValueArray.append(userAccelerationZ)
            self.updateGraph()
            
        }
    }
    
    
    func calculateAverageSpeed(myArray : Array<Double>) -> Double {
        
        let arraySum = myArray.reduce(0) { $0 + $1 }
        return arraySum / Double(myArray.count)
        
    }
    
    
    
    
    @IBAction func startButton(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable {
            
            if isDeviceMotionOn {
                isDeviceMotionOn = false
                motionManager.stopDeviceMotionUpdates()
                startButtonOutlet.setTitle("START", for: .normal)
            } else {
                isDeviceMotionOn = true
                startDeviceMotion()
                startButtonOutlet.setTitle("STOP", for: .normal)
            }
        }
    }

    
    @IBAction func clearChartButton(_ sender: Any) {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
            resetAllValues()
            reloadInputViews()
            motionManager.startDeviceMotionUpdates()
            startDeviceMotion()
            isDeviceMotionOn = true
        }
    }
    
    func resetAllValues() {
        
        xValueArray.removeAll()
        yValueArray.removeAll()
        zValueArray.removeAll()
        accelerationArray.removeAll()
        tempArray.removeAll()
        maxValue = 0
        minValue = 0
        currentNode = 0
        minValueLabel.text = "0"
        maxValueLabel.text = "0"
        averageLabel.text = "0"
        
        
    }
    
}

