//
//  DatabaseManager.swift
//  DataStorage
//
//  Created by Użytkownik Gość on 15.12.2017.
//  Copyright © 2017 Użytkownik Gość. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    var context: NSManagedObjectContext?;
    var appDelegate: AppDelegate?;
    
    func initCoreData() {
        appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDelegate!.persistentContainer.viewContext
    }
    
    func createSensors() {
        var sensors: [Sensor] = []
        
        do {
            sensors = try context!.fetch(Sensor.fetchRequest())
            if sensors.count == 0 {
                for sensorNumber in 1...20 {
                    let sensor = Sensor(context: context!)
                    let sensorNumberString = (sensorNumber < 10 ? "0" + String(sensorNumber) : String(sensorNumber))
                    sensor.name = "S" + sensorNumberString
                    sensor.sensorDescription = "Sensor number " + String(sensorNumber)
                }
                appDelegate!.saveContext()
            }
        }
        catch {
            print("Fetching Failed")
        }
    }


    func readSensorData() -> [SensorData] {
        var sensorsData: [SensorData] = []
        
        do {
            sensorsData = try context!.fetch(SensorData.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
        
        return sensorsData
    }
    
    func findMinMaxTimestamps() -> [Int] {
        return [1]
    }
    
    func findAvgSensorValue() -> Double {
        return 1.0
    }
    
    func findSensorDataAvgAndCountForSensors() -> [(String, Double, Int)] {
        return [("error", 1.0, 1)]
    }
    
    func readSensors() -> [Sensor] {
        var sensors: [Sensor] = []
        
        do {
            sensors = try context!.fetch(Sensor.fetchRequest())
        }
        catch {
            print("Fetching Failed")
        }
        
        return sensors
    }
    
    func deleteSensorData() {
        
    }
    
    func insertDataToDb(numberOfData: Int) {
        var sensors: [Sensor] = readSensors()
        
        for _ in 1...(numberOfData) {
            let sensorData = SensorData(context: context!)
            let randomValue = Int(arc4random_uniform(UInt32(sensors.count - 1)))
            sensorData.sensor = sensors[randomValue]
            sensorData.date = Int32(arc4random_uniform(UInt32(Date().timeIntervalSince1970)))
            sensorData.data = Float(arc4random_uniform(100))
        }
        
        appDelegate!.saveContext()
    }
}
