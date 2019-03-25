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
    
    
    var timeInterval : Double = 20
    var acceleration = 0.0
    var isDeviceMotionOn = false
    var currentNode = 0
    var userActivitySpeed = [Double]() // användarens "medelhastighet"

    
    
    
    // Array för att spara värden till användarens medelhastighet
    var activityFactorArray = [Double]()
    
    // -------------------
    
    var cheatingDetected = true
    
    
    
    
    var tempArray = [Double]() // tillfällig array att förvara värden i

    var axisValueArray = [Double]() // Array för tre axlarna
    var userActivityArray = [Double]() // Array för filtrerad aktivitet

    var rechargeRate = 0.0 // variabel för användarens graph (vid ökning stiger kurvan i grafen och vice versa).
    var rechargeBaseRate = 0.1
    
    
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
        
        // Array för
       /* for i in 0..<activityFactorArray.count {
            
            let activityValue = ChartDataEntry(x: Double(i), y: activityValueArray[i])
            activityChartEntry.append(activityValue)
        }*/
        
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

        currentNode += 1 // nedanför innan
        
        self.chtChart.setVisibleXRangeMinimum(250)
        self.chtChart.setVisibleXRangeMaximum(250)
        
        self.chtChart.leftAxis.axisMinimum = 0 // var grafen börjar, på vilken punkt
        self.chtChart.rightAxis.axisMinimum = 0
        
        self.chtChart.notifyDataSetChanged()
        self.chtChart.moveViewToX(Double(currentNode))
        
    }
    
    
    // Räknar ut medelhastigheten under viss tid för användaren
    func calculateAverageSpeed(myArray : Array<Double>) -> Double {
        
        let arraySum = myArray.reduce(0) { $0 + $1 }
        return arraySum / Double(myArray.count)
        
        // TEST
        if arraySum > 0.1 {
            return arraySum
        } else {
            return 0
        }
    }
    
    
    func fetchUserData() {
        
        if currentNode % 10 == 0 {
            tempArray = axisValueArray
            let averageActivity = calculateAverageSpeed(myArray: tempArray) // TEST??
            userActivityArray.append(averageActivity)
            
            // Töm arrayen
            tempArray.removeAll()
        }
    }
    
    func startDeviceMotion() {
        
        if CMMotionManager.sharedMotion.isDeviceMotionAvailable {
            
            CMMotionManager.sharedMotion.deviceMotionUpdateInterval = 1/self.timeInterval //How many nodes per second?(Hertz)
            CMMotionManager.sharedMotion.startDeviceMotionUpdates(to: .main) { (motion, error) in
                
                guard let motion = motion else {
                    return
                }
                
                let gravity = motion.gravity
                let userAcceleration = motion.userAcceleration
                
                // Skicka värdet av gravity & userAcceleration till funktionen
                self.userActivityFiler(gravity: gravity, userAcceleration: userAcceleration)

                
                // lägg i userActivityFilter???
                let allAxisAcceleration = abs(motion.userAcceleration.x + motion.userAcceleration.y + motion.userAcceleration.z)
                
                self.axisValueArray.append(allAxisAcceleration)
                self.fetchUserData()
            
                
                // TEST UTAN userAcceleration i Z-led (kanske testa, x + z)
                //let userAccel = userAccelerationX + userAccelerationZ
                self.updateGraph()
            }
        }
    }
    
   // Tar in användarens data och filtrerar den för att se om den är godkänd.
    func userActivityFiler(gravity : CMAcceleration, userAcceleration: CMAcceleration) -> Bool {
        
        let acceleration = userAcceleration.x + userAcceleration.y + userAcceleration.z
       
            
        if abs(gravity.x) > 0.5 && abs(gravity.y) < 0.25 && userAcceleration.z > 0.65 && userAcceleration.y > 0.6 {

            
            //if abs(userAcceleration.x) > 0.35 && abs(userAcceleration.x) > abs(userAcceleration.y) && abs(userAcceleration.z) > abs(userAcceleration.y) {
         
                // Godkänd aktivitet
                cheatingDetected = false
                self.validStepsIndicator.backgroundColor = .green
                
            } else {
               
            cheatingDetected = true
                self.validStepsIndicator.backgroundColor = .red
            }
        /*} else {
            userIsSteping = false
            self.validStepsIndicator.backgroundColor = .red
        }*/
        return cheatingDetected
        
    }
    
    
    // Funktion för att rita ut på grafen (tar in värdet av den filtrerade aktivitete)
    func updateActivityGraph(value : Bool, acceleration : Double) {
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        // Ska ta in ett värde...
        
        /*
        if currentNode % 20 == 0 {
        
            
            // Ha bara formeln
    
            // Inte så här.....
            if value {
                // grafen stiger (lite långsammare)
                if rechargeRate > 1.5 {
                    rechargeRate = 1.5
                } else {
                    //rechargeRate += rechargeBaseRate * (1 + acceleration)
                    rechargeRate += 0.1
                    print("plus")
                }
        }
        else {
                // grafen sjunker (lite snabbare)
                if rechargeRate <= 0  {
                    rechargeRate = 0
                    print("ligger på botten")
                } else {
                    rechargeRate -= 0.2
                    print("sjunker")
                }
            }
        
    }
        // appenda i array(?)
        userActivityArray.append(rechargeRate)*/
    }
    
    // Returnerar om användaren fuskar
    func isCheatingHappening() -> Bool {
        
        return true
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

