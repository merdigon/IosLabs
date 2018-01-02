//
//  DatabaseManager.swift
//  DataStorage
//
//  Created by Użytkownik Gość on 15.12.2017.
//  Copyright © 2017 Użytkownik Gość. All rights reserved.
//

import UIKit

class DatabaseManager: NSObject {
    var db: OpaquePointer? = nil
    
    
    func openConnection() {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbFilePath = NSURL(fileURLWithPath: docDir).appendingPathComponent("demo.db")?.path
        
        if sqlite3_open(dbFilePath, &db) == SQLITE_OK {
            print("ok")
            createDatabase()
        } else {
            print("fail")
        }
    }
    
    func createDatabase() {
        let createSensor = "CREATE TABLE IF NOT EXISTS sensor (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(50), description VARCHAR(150));"
        print(sqlite3_exec(db, createSensor, nil, nil, nil))
        let createSensorData = "CREATE TABLE IF NOT EXISTS sensorData (id INTEGER PRIMARY KEY AUTOINCREMENT, date DEFAULT CURRENT_TIMESTAMP NOT NULL, data VARCHAR(150), id_sensor integer, FOREIGN KEY(id_sensor) REFERENCES sensor(id));"
        print(sqlite3_exec(db, createSensorData, nil, nil, nil))
        
        let clearSensorDataSql = "DELETE FROM sensorData";
        print(sqlite3_exec(db, clearSensorDataSql, nil, nil, nil))
        
        let checkIfExistsSensorsSql = "SELECT COUNT(id) FROM sensor";
        var stmt: OpaquePointer? = nil
        sqlite3_prepare_v2(db, checkIfExistsSensorsSql, -1, &stmt, nil)
        if sqlite3_step(stmt) == SQLITE_ROW {
            if Int(sqlite3_column_int(stmt, 0)) == 0 {
                for sensorNumber in 1...20 {
                    let sensorNumberString = (sensorNumber < 10 ? "0" + String(sensorNumber) : String(sensorNumber))
                    let sensorName = "S" + sensorNumberString
                    let sensorDescription = "Sensor number " + String(sensorNumber)
                    let insertSensorsSql = "INSERT INTO sensor(name, description) VALUES ('\(sensorName)', '\(sensorDescription)');"
                    
                    print(sqlite3_exec(db, insertSensorsSql, nil, nil, nil))
                }
            }
        }
        sqlite3_finalize(stmt)
    }
    
    func readSensorData() -> [SensorData] {
        var sensorDatas = [SensorData]()
        
        var stmt: OpaquePointer? = nil
        let selectSQL = "SELECT sd.date, sd.data, s.name FROM sensorData sd LEFT OUTER JOIN sensor s on(s.id = sd.id_sensor) ORDER BY sd.data;"
        sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let sensorData = SensorData(sensorName: String(cString: sqlite3_column_text(stmt, 2)),
                                        date: String(cString: sqlite3_column_text(stmt, 0)),
                                        data: String(cString: sqlite3_column_text(stmt, 1)))
            sensorDatas.append(sensorData);
            print("Dana z sensora \(sensorData.sensorName), \(sensorData.date), \(sensorData.data).")
        }
        sqlite3_finalize(stmt)
        return sensorDatas
    }
    
    func readSensors() -> [Sensor] {
        var sensors = [Sensor]()
        
        var stmt: OpaquePointer? = nil
        let selectSQL = "SELECT id, name, description FROM sensor ORDER BY id;"
        sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nil)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let sensor = Sensor(id: Int(sqlite3_column_int(stmt, 0)),
                                        name: String(cString: sqlite3_column_text(stmt, 1)),
                                        description: String(cString: sqlite3_column_text(stmt, 2)))
            sensors.append(sensor);
            print("Dana z sensora \(sensor.name), \(sensor.description).")
        }
        sqlite3_finalize(stmt)
        return sensors
    }
    
    func insertDataToDb(numberOfData: Int) {
        
        let selectSQL = "SELECT id, name FROM sensor;"
        var ids = [Int]()
        var stmt: OpaquePointer? = nil
        print(sqlite3_prepare_v2(db, selectSQL, -1, &stmt, nil))
        while sqlite3_step(stmt) == SQLITE_ROW {
            ids.append(Int(sqlite3_column_int(stmt, 0)))
        }
        sqlite3_finalize(stmt)
        
        for _ in 1...(numberOfData) {
            let sensorId = ids[Int(arc4random_uniform(UInt32(ids.count))) - 1]
            let date = Int(arc4random_uniform(UInt32(Date().timeIntervalSince1970)))
            let data = Int(arc4random_uniform(100))
            let insertSQL = "INSERT INTO sensorData (date, data, id_sensor) VALUES ('\(date)', '\(data)', \(sensorId));"
            sqlite3_exec(db, insertSQL, nil, nil, nil)
        }
        
    }
}
