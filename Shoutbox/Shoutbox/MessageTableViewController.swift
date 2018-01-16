//
//  MessageTableViewController.swift
//  Shoutbox
//
//  Created by merdigon on 16/01/2018.
//  Copyright © 2018 merdigon. All rights reserved.
//

import UIKit
import Alamofire

class MessageTableViewController: UITableViewController {

    var messages: [Message] = []
    let urlAddress = "https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func addMessage_click(_ sender: Any) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name and message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        } )
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let messageValue = alertController.textFields?[1].text
            
            let parameters: Parameters = [
                "name": name!,
                "message": messageValue!
            ]
            
            Alamofire.request(self.urlAddress, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseString {response in
                if response.result.error == nil {
                    self.reloadData()
                }
            }
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadData()
    }
    
    func reloadData() {
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss" //Your date format
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+1:00")
            
            var readedMessages: [Message] = []
            
            Alamofire.request(urlAddress).responseJSON(completionHandler: { response in
                print("dupa")
                let jsonValue = response.result.value as! NSDictionary
                let messageArray = jsonValue.object(forKey: "entries") as! NSArray
                
                for messageValue in messageArray {
                    let messageDict = messageValue as! NSDictionary
                    let timestampValue = messageDict.object(forKey: "timestamp") as! String
                    let newMessage = Message(
                        author: messageDict.object(forKey: "name") as! String,
                        message: messageDict.object(forKey: "message") as! String,
                        timestamp: dateFormatter.date(from: (timestampValue))!)
                    readedMessages.append(newMessage)
                }
                self.messages = readedMessages.sorted(by: { $0.timestamp > $1.timestamp })
                self.tableView.reloadData()
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "\(Int(Int(Date().timeIntervalSince(messages[indexPath.row].timestamp))/60)) minutes ago"
        cell.detailTextLabel?.text = "\(messages[indexPath.row].author) wrote: \(messages[indexPath.row].message)"

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
