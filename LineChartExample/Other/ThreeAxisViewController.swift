//
//  ThreeAxisViewController.swift
//  LineChartExample
//
//  Created by Henrik Jangefelt on 2019-03-19.
//  Copyright © 2019 Osian. All rights reserved.
//

import UIKit
import Charts
import CoreMotion

class ThreeAxisViewController: UIViewController {

    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var clearButtonOutlet: UIButton!
    @IBOutlet weak var validStepsIndicator: UIView!
    
    var timeInterval : Double = 20
    let motionManager = CMMotionManager()
    
    var acceleration = 0.0
   
    
    var isDeviceMotionOn = false
    var currentNode = 0
    var userActivitySpeed = [Double]() // användarens "medelhastighet"
    //var userActivityNode = 0
    
    var xValueArray = [Double]()
    var yValueArray = [Double]()
    var zValueArray = [Double]()
    
    var accelerationArray = [Double]()
    var tempArray = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    func updateGraph() {
        
        var xLineChartEntry = [ChartDataEntry]() // X värdet
        var yLineChartEntry = [ChartDataEntry]() // Y värdet
        var zLineChartEntry = [ChartDataEntry]()
        
        // numbers.count gemensam array för alla axlarna
        for i in 0..<accelerationArray.count {
            
            let xValue = ChartDataEntry(x: Double(i), y: xValueArray[i])
            let yValue = ChartDataEntry(x: Double(i), y: yValueArray[i])
            let zValue = ChartDataEntry(x: Double(i), y: zValueArray[i])
            
            xLineChartEntry.append(xValue)
            yLineChartEntry.append(yValue)
            zLineChartEntry.append(zValue)
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
        
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(lineX) //Adds the line to the dataSet
        data.addDataSet(lineY)
        data.addDataSet(lineZ)
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
            
            //print("Average X: \(averageX), Y: \(averageY), Z: \(averageZ)")
            
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
                
                var userAcceleration = motion.userAcceleration
                var gravity = motion.gravity
            
               
                
                /*var maxGravityX = 0.0
                var minGravityX = 0.1
                
                if gravity.x > maxGravityX {
                    
                    maxGravityX = gravity.x
                    print("Max grav.x: \(maxGravityX)")
                }
                if gravity.x < minGravityX {
                    minGravityX = gravity.x
                    print("Min grav.x: \(minGravityX)")
                }*/
                
               
                
                //if abs(gravity.x) > abs() && abs(gravity.z) > abs(gravity.y) {
                if abs(gravity.x) > abs(gravity.y) && abs(gravity.z) > abs(gravity.y) {

                    if abs(userAcceleration.x) > 0.35 && abs(userAcceleration.x) > abs(userAcceleration.z) && abs(userAcceleration.z) > abs(userAcceleration.y) {
                        
                        
                        self.validStepsIndicator.backgroundColor = .green
                    
                        
                    } else {
                        self.validStepsIndicator.backgroundColor = .red
                    }
                } else {
                    self.validStepsIndicator.backgroundColor = .red
                }
                
                
                // TEST UTAN userAcceleration i Z-led (kanske testa, x + z)
                let userAccel = userAcceleration.x + userAcceleration.z

                // lägg eventuellt till z
                /*if abs(gravity.x) > 0.6 && abs(gravity.y) < 0.35 && abs(userAccel) > 0.35 && abs(userAccel) < 1.7 {
                    self.validStepsIndicator.backgroundColor = .green
                } else {
                    self.validStepsIndicator.backgroundColor = .red
                }*/
                
                
              
                
                
                // Rörelse i någon av axlarna
                //let userAccelerationXYZ = userAcceleration.x + userAcceleration.y + userAcceleration.z
                // min accel 0.35, max 1,7
                
                /*if gravX > 0.6 && gravY < 0.35 && gravZ < 0.1 {
                    print("Absolut rätt hållning")
                    if userAccel > 0.35 && userAccel < 1.7 {
                        print("Registrerar stampande")
                    }
                }*/
                
                
                
               
                
                
                    /*if (gravity.x < 0.95 && userAcceleration.x > 0.3) || (gravity.y < -0.95 && userAcceleration.y > 0.3) || (gravity.z < -0.95 && userAcceleration.z > 0.3) {
                        self.validStepsIndicator.backgroundColor = .green
                        
                        if gravity.x < 0.95 && userAcceleration.x > 0.3 {
                            //print("Hopp i x led")
                        }
                        if gravity.y < -0.95 && userAcceleration.y > 0.3 {
                            //print("Hopp i y led")
                        }
                        if gravity.z < -0.95 && userAcceleration.z > 0.3 {
                            //print("Hopp i z led")
                        }
                    } else {
                        self.validStepsIndicator.backgroundColor = .red
                    }*/
                
                    
                    let userAccelerationXYZ = round((userAcceleration.x + userAcceleration.y + userAcceleration.z) * 100) / 100
                    
                    self.accelerationArray.append(userAccelerationXYZ)
                    self.xValueArray.append(motion.userAcceleration.x)
                    self.yValueArray.append(motion.userAcceleration.y)
                    self.zValueArray.append(motion.userAcceleration.z)
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
        currentNode = 0
       
        
        
    }
    
    
}
