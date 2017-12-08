//
//  ViewController.swift
//  DataStorage
//
//  Created by Użytkownik Gość on 01.12.2017.
//  Copyright © 2017 Użytkownik Gość. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var db: OpaquePointer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dbFilePath = NSURL(fileURLWithPath: docDir).appendingPathComponent("demo.db")?.path
        
        if sqlite3_open(dbFilePath, &db) == SQLITE_OK {
            print("ok")
            createDatabase()
        } else {
            print("fail")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDatabase() {
        let createSensor = "CREATE TABLE IF NOT EXISTS sensor (id INTEGER PRIMARY KEY AUTOINCREMENT, name character varying(150), description character varying(150));"
        print(sqlite3_exec(db, createSensor, nil, nil, nil))
        let createSensorData = "CREATE TABLE IF NOT EXISTS sensorData (id INTEGER PRIMARY KEY AUTOINCREMENT, date DEFAULT CURRENT_TIMESTAMP NOT NULL, data character varying(150), id_sensor integer, FOREIGN KEY(id_sensor) REFERENCES sensor(id));"
        print(sqlite3_exec(db, createSensorData, nil, nil, nil))
    }
    
    func readSensorData() {
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
    }

}

