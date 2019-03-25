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
    @IBOutlet weak var startBtnOutlet: UIButton!
    @IBOutlet weak var clearBtnOutlet: UIButton!
    @IBOutlet weak var validStepsIndicator: UIView!
    
    var timeInterval : Double = 20 // Updaterings interval/frekvens
    var isDeviceMotionOn = false // variabel för Start och Stopp
    
    var currentNode = 0 // Start node

    // Array för att spara värden till användarens medelhastighet
    var activityFactorArray = [Double]() // kan nog slängas
    
    // -------------------
    
    var cheatingDetected = true
    

    var tempArray = [Double]() // tillfällig array att förvara värden i

    var axisValueArray = [Double]() // Array för tre axlarna
    var userActivityArray = [Double]() // Array för filtrerad aktivitet

    var rechargeRate = 0.0 // variabel för användarens graph (vid ökning stiger kurvan i grafen och vice versa).
    var rechargeBaseRate = 0.1
    
    var value = 0.0  // Starta på 0, uppdatera var 10s och kolla nytt värde
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateGraph() {
        
        var axisLineChartEntry = [ChartDataEntry]() // X, Y & Z värdet
        var userLineChartEntry = [ChartDataEntry]() // filtrerade aktivitets värdet
        
        // axisValueArray gemensam array för alla axlarna (X, Y, Z)
        for i in 0..<axisValueArray.count {

            let axisValue = ChartDataEntry(x: Double(i), y: axisValueArray[i])
            let userValue = ChartDataEntry(x: Double(i), y: userActivityArray[i])
            
            axisLineChartEntry.append(axisValue) // x y z
            userLineChartEntry.append(userValue) // användarens aktivitet
        }
      
        let lineAxis = LineChartDataSet(values: axisLineChartEntry, label: "userAcceleration (X+Y+Z)")
        lineAxis.colors = [NSUIColor.blue]
        lineAxis.circleRadius = 0
        
        let lineActivity = LineChartDataSet(values: userLineChartEntry, label: "Filtered userActivity")
        lineActivity.colors = [NSUIColor.red]
        lineActivity.circleRadius = 0
        
        let data = LineChartData() // Object that will be added to the chart
        data.addDataSet(lineAxis) //Adds the line to the dataSet
        data.addDataSet(lineActivity)
        chtChart.data = data //it adds the chart data to the chart and causes an update

        currentNode += 1 // (nedanför innan)
        
        self.chtChart.setVisibleXRangeMinimum(250)
        self.chtChart.setVisibleXRangeMaximum(250)
        
        self.chtChart.leftAxis.axisMinimum = 0 // var grafen börjar, på vilken punkt
        self.chtChart.rightAxis.axisMinimum = 0
        
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        
    }
    
    // Påbörja hämtning av användar data
    func startDeviceMotion() {
        
        if CMMotionManager.sharedMotion.isDeviceMotionAvailable {
            
            CMMotionManager.sharedMotion.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
            CMMotionManager.sharedMotion.startDeviceMotionUpdates(to: .main) { (motion, error) in
                
                guard let motion = motion else {
                    return
                }
                
                let gravity = motion.gravity
                let userAcceleration = motion.userAcceleration
                
                // Skicka datan till filter för att kolla om aktiviteten är godkänd
                self.userActivityFiler(gravity: gravity, userAcceleration: userAcceleration)

                //print(self.cheatingDetected)

                let allAxisAcceleration = abs(motion.userAcceleration.x + motion.userAcceleration.y + motion.userAcceleration.z)
                
                self.axisValueArray.append(allAxisAcceleration)
                self.updateActivity()
        
                
                self.updateGraph()
            }
        }
    }
    
    // Filtrerar användarens input (rörelser) för att se om dem är godkända.
    func userActivityFiler(gravity : CMAcceleration, userAcceleration: CMAcceleration) -> Bool {
        
        let acceleration = userAcceleration.x + userAcceleration.y + userAcceleration.z
        
        // Kolla efter godkänd rörelse (kanske ignorera userAcceleration Z och Y)
        
        if abs(gravity.x) > 0.85 && abs(userAcceleration.x) > 0.06 {

            
            print("OKEY")
            //if abs(userAcceleration.x) > 0.35 && abs(userAcceleration.x) > abs(userAcceleration.y) && abs(userAcceleration.z) > abs(userAcceleration.y) {
            
            // Godkänd aktivitet
            cheatingDetected = false
            self.validStepsIndicator.backgroundColor = .green
            
        } else {
            print("NOT OKEy")
            print("grav x\(abs(gravity.x))")
            print("user x\(abs(userAcceleration.x))")
            cheatingDetected = true
            self.validStepsIndicator.backgroundColor = .red
        }
        /*} else {
         userIsSteping = false
         self.validStepsIndicator.backgroundColor = .red
         }*/
        //print(cheatingDetected)
        return cheatingDetected
    }

    
    func updateActivity() {
        
        
        userActivityArray.append(value)
        
        // var tionde nod
        if currentNode % 10 == 0 {
            
            tempArray = axisValueArray
            let averageActivity = calculateAverageSpeed(myArray: tempArray)
            //value = averageActivity
            
            //----------TEST--------------
            if cheatingDetected {
                value = -averageActivity * 3
            } else {
                value = rechargeBaseRate * (1 + averageActivity)
            }
            //---------------------------
            
            tempArray.removeAll()

            
        }
        
        // lägger till value oavsett.....
        userActivityArray.append(value)

        
    }
    
    // Räknar ut medelhastigheten under viss tid för användaren
    func calculateAverageSpeed(myArray : Array<Double>) -> Double {
        
        let arraySum = myArray.reduce(0) { $0 + $1 }
        return arraySum / Double(myArray.count)
        
        //---------TEST-------(Returnera först om det är över en viss hastighet)
        /*let averageSpeed = arraySum / Double(myArray.count)
        if averageSpeed > 0.1 {
            return averageSpeed
        } else {
            return 0
        }*/
    }
    
    
  
    
    
    
    
  
    // START OCH CLEAR BUTTONS
    @IBAction func startBtn(_ sender: Any) {
        isDeviceMotionOn = !isDeviceMotionOn
        isDeviceMotionOn ? startPress() : stopPress()
        }
    
    func startPress() {
        startDeviceMotion()
        startBtnOutlet.setTitle("STOP", for: .normal)
    }
    
    func stopPress() {
        CMMotionManager.sharedMotion.stopDeviceMotionUpdates()
        startBtnOutlet.setTitle("START", for: .normal)
    }
    
    
    @IBAction func clearChartBtn(_ sender: Any) {
        
            CMMotionManager.sharedMotion.stopDeviceMotionUpdates()
            resetAllValues()
            reloadInputViews()
            CMMotionManager.sharedMotion.startDeviceMotionUpdates()
            startDeviceMotion()
            isDeviceMotionOn = true
    }
    
    func resetAllValues() {
        axisValueArray.removeAll()
        tempArray.removeAll()
        userActivityArray.removeAll()
        currentNode = 0
    }
    
}

