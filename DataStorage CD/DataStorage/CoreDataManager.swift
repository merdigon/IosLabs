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
        let moc = appDelegate!.persistentContainer.viewContext
        
        var resultValues: [Int] = []
        
        do{
            let frMin = NSFetchRequest<NSFetchRequestResult>(entityName:"SensorData")
            frMin.resultType = .dictionaryResultType
            let edMin = NSExpressionDescription()
            edMin.name = "MinimumDate"
            edMin.expression = NSExpression(format: "@min.date")
            edMin.expressionResultType = .integer32AttributeType
            frMin.propertiesToFetch = [edMin]
        
            var resultMin = try moc.fetch(frMin)
            resultValues.append((resultMin[0] as! NSDictionary).value(forKey: "MinimumDate")! as! Int)
            
            
            let frMax = NSFetchRequest<NSFetchRequestResult>(entityName:"SensorData")
            frMax.resultType = .dictionaryResultType
            let edMax = NSExpressionDescription()
            edMax.name = "MaximumDate"
            edMax.expression = NSExpression(format: "@max.date")
            edMax.expressionResultType = .integer32AttributeType
            frMax.propertiesToFetch = [edMax]
            
            var resultMax = try! moc.fetch(frMax)
            resultValues.append((resultMax[0] as! NSDictionary).value(forKey: "MaximumDate")! as! Int)
        }
        catch {
            NSLog("Error fetching entity: %@", error.localizedDescription)
        }
        return resultValues
    }
    
    func findAvgSensorValue() -> Double {
        let moc = appDelegate!.persistentContainer.viewContext
        
        do{
            let frAvg = NSFetchRequest<NSFetchRequestResult>(entityName:"SensorData")
            frAvg.resultType = .dictionaryResultType
            let edAvg = NSExpressionDescription()
            edAvg.name = "AverageData"
            edAvg.expression = NSExpression(format: "@avg.data")
            edAvg.expressionResultType = .doubleAttributeType
            frAvg.propertiesToFetch = [edAvg]
            
            var resultAvg = try moc.fetch(frAvg)
            let resultValue = ((resultAvg[0] as! NSDictionary).value(forKey: "AverageData")! as! Double)
            return resultValue
        }
        catch {
            NSLog("Error fetching entity: %@", error.localizedDescription)
        }
        
        return -1.0
    }
    
    func findSensorDataAvgAndCountForSensors() -> [(String, Double, Int)] {
        let moc = appDelegate!.persistentContainer.viewContext
        var sensorResultArray:[(String, Double, Int)] = []
        
        do{
            let frAC = NSFetchRequest<NSFetchRequestResult>(entityName:"SensorData")
            frAC.resultType = .dictionaryResultType
            frAC.propertiesToFetch = ["sensor"]
            frAC.propertiesToGroupBy = ["sensor.name"]
            let edAvg = NSExpressionDescription()
            edAvg.name = "AverageData"
            edAvg.expression = NSExpression(format: "@avg.data")
            edAvg.expressionResultType = .doubleAttributeType
            let edCount = NSExpressionDescription()
            let keypathExp1 = NSExpression(forKeyPath: "data")
            edCount.expression = NSExpression(forFunction: "count:", arguments: [keypathExp1])
            edCount.name = "CountData"
            edCount.expressionResultType = .integer32AttributeType
            frAC.propertiesToFetch = ["sensor.name", edAvg, edCount]
            
            let resultArray = try moc.fetch(frAC)
            
            for res in resultArray {
                let dict = (res as! NSDictionary)
                let sensorName = dict.value(forKey: "sensor.name")! as! String
                let sensorAvg = dict.value(forKey: "AverageData")! as! Double
                let sensorCount = dict.value(forKey: "CountData")! as! Int
                sensorResultArray.append((sensorName, sensorAvg, sensorCount))
            }
            
            return sensorResultArray
        }
        catch {
            NSLog("Error fetching entity: %@", error.localizedDescription)
        }

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
        let moc = appDelegate!.persistentContainer.viewContext
        for sensorData in readSensorData() {
            moc.delete(sensorData)
        }
        
        try? moc.save()
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
