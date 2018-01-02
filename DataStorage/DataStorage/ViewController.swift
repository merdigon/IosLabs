//
//  ViewController.swift
//  DataStorage
//
//  Created by Użytkownik Gość on 01.12.2017.
//  Copyright © 2017 Użytkownik Gość. All rights reserved.
//

import UIKit

var dbManager = DatabaseManager()

class ViewController: UIViewController {
        
    @IBOutlet weak var recordsQuantity: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonClick(_ sender: Any) {
            let numbers = Int(recordsQuantity.text!)
            dbManager.insertDataToDb(numberOfData: numbers!)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbManager.openConnection()
                // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}

