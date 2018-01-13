//
//  ViewController.swift
//  DataStorage
//
//  Created by Użytkownik Gość on 01.12.2017.
//  Copyright © 2017 Użytkownik Gość. All rights reserved.
//

import UIKit

var cdManager = CoreDataManager()

class ViewController: UIViewController {
        
    @IBOutlet weak var recordsQuantity: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var outputLabel: UITextView!
    
    @IBAction func addButtonClick(_ sender: Any) {
            let numbers = Int(recordsQuantity.text!)
            cdManager.insertDataToDb(numberOfData: numbers!)
    }
    
    @IBAction func deleteButtonClick(_ sender: Any) {
        cdManager.deleteSensorData()
    }
    
    @IBAction func kExperimentClick(_ sender: Any) {
        performExperiment(numberOfSamples: 1000)
    }
    
    @IBAction func mExperimentClick(_ sender: Any) {
        performExperiment(numberOfSamples: 1000000)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cdManager.initCoreData()
        cdManager.createSensors()
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performExperiment(numberOfSamples: Int) {
        
        outputLabel.text = "Dodawanie \(numberOfSamples) próbek\n"
        var startTime = NSDate()
        cdManager.insertDataToDb(numberOfData: numberOfSamples)
        var finishTime = NSDate()
        var measuredTime = finishTime.timeIntervalSince(startTime as Date)
        outputLabel.text = outputLabel.text + "Zakończono po \(measuredTime)\n\n"
        
        outputLabel.text = outputLabel.text + "Znajdowanie timestampów\n"
        startTime = NSDate()
        let minMaxStemp = cdManager.findMinMaxTimestamps()
        finishTime = NSDate()
        measuredTime = finishTime.timeIntervalSince(startTime as Date)
        outputLabel.text = outputLabel.text + "Najmniejszy timestamp: \(minMaxStemp[0]), nawiększy timestamp: \(minMaxStemp[1]). Zakończone po \(measuredTime).\n\n"
        
        outputLabel.text = outputLabel.text + "Znajdowanie średniej wartości"
        startTime = NSDate()
        let avgValue = cdManager.findAvgSensorValue()
        finishTime = NSDate()
        measuredTime = finishTime.timeIntervalSince(startTime as Date)
        outputLabel.text = outputLabel.text + "Średnia wartość: \(avgValue). Zakończone po \(measuredTime).\n\n"
        
        outputLabel.text = outputLabel.text + "Wyniki pogrupowane po sensorach"
        startTime = NSDate()
        let sensorAvgCountValues = cdManager.findSensorDataAvgAndCountForSensors()
        finishTime = NSDate()
        measuredTime = finishTime.timeIntervalSince(startTime as Date)
        for sensorData in sensorAvgCountValues {
            let (sensorName, sensorAvg, sensorReadCount) = sensorData
            outputLabel.text = outputLabel.text + "\(sensorName): \(sensorReadCount) razy, średnia \(sensorAvg)\n"
        }
        outputLabel.text = outputLabel.text + "Zakończone po \(measuredTime).\n\n"
    }

}

