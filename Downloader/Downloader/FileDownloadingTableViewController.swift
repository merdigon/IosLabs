//
//  FileDownloadingTableViewController.swift
//  ImageDownloader
//
//  Created by merdigon on 18/01/2018.
//  Copyright © 2018 merdigon. All rights reserved.
//

import UIKit

class FileDownloadingTableViewController: UITableViewController, URLSessionDownloadDelegate, UIApplicationDelegate  {
    


    var downloadingFiles: [FileDownloadingStatus] = []
    var downloadStartTime: NSDate?
    
    var imagesToDownload : [(String, String)] =
        [ ("Rodzinka", "https://upload.wikimedia.org/wikipedia/commons/0/04/Dyck,_Anthony_van_-_Family_Portrait.jpg"),
          ("Grubasek", "https://upload.wikimedia.org/wikipedia/commons/0/06/Master_of_Flémalle_-_Portrait_of_a_Fat_Man_-Google_Art_Project_(331318).jpg"),
          ("Młoda", "https://upload.wikimedia.org/wikipedia/commons/c/ce/Petrus_Christus_-_Portrait_of_a_Young_Woman_-_Google_Art_Project.jpg"),
          ("Starucha", "https://upload.wikimedia.org/wikipedia/commons/3/36/Quentin_Matsys_-_A_Grotesque_old_woman.jpg"),
          ("Bitwa", "https://upload.wikimedia.org/wikipedia/commons/c/c8/Valmy_Battle_painting.jpg") ]
    
    @IBAction func playButton_Click(_ sender: Any) {
        downloadStartTime = NSDate()
        for imageLink in imagesToDownload {
            if let imageURL: URL = URL(string: imageLink.1) {
                let config = URLSessionConfiguration.background(withIdentifier:"\(imageLink.1)")
                config.sessionSendsLaunchEvents = true
                config.isDiscretionary = true
                let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
                let task = session.downloadTask(with: imageURL)
            
                let progressObject = FileDownloadingStatus()
                progressObject.imageName = imageLink.0
                progressObject.downloadPercentStatus = 0.0
                progressObject.imageUrl = imageLink.1
                
                downloadingFiles.append(progressObject)
                let now = NSDate()
                print("\(now.timeIntervalSince(downloadStartTime! as Date)) Start downloading file \(imageLink.0)")
                task.resume()
            }
        }
        
        self.tableView.reloadData()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for var downloadingProgress in downloadingFiles {
            if downloadingProgress.imageUrl == downloadTask.currentRequest?.url?.absoluteString {
                downloadingProgress.downloadPercentStatus = Double((100 * totalBytesWritten)/totalBytesExpectedToWrite)
                
                if downloadingProgress.downloadPercentStatus > 50 && !downloadingProgress.fiftyPercentStageWasLogged {
                    print("\(NSDate().timeIntervalSince(downloadStartTime! as Date)) 50% downloading file \(downloadingProgress.imageName)")
                    downloadingProgress.fiftyPercentStageWasLogged = true
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void)
    {
        completionHandler()
    }
    
    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        handleImageDownloadingFinish(urlPath: (downloadTask.currentRequest?.url?.absoluteString)!, locationPath: location)
    }
    
    func handleImageDownloadingFinish(urlPath: String, locationPath: URL) {
        for var downloadingProgress in downloadingFiles {
            if downloadingProgress.imageUrl == urlPath {
                print("\(NSDate().timeIntervalSince(downloadStartTime! as Date)) Finished downloading file \(downloadingProgress.imageName)")
                downloadingProgress.downloadPercentStatus = 100
                
                let data = try? Data(contentsOf: locationPath)
                downloadingProgress.image = UIImage(data: data!)!
                
                detectFaces(downloadedImage: downloadingProgress)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func detectFaces(downloadedImage: FileDownloadingStatus) {
        let queue = DispatchQueue(label: "faceDetection_\(downloadedImage.imageName)")
        queue.async {
            print("\(NSDate().timeIntervalSince(self.downloadStartTime! as Date)) Begin face detecting of file \(downloadedImage.imageName)")
            let faceDetectionTask = CIDetector(ofType: "CIDetectorTypeFace", context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            let faceFeatures = faceDetectionTask?.features(in: CIImage(image: downloadedImage.image!)!)
            downloadedImage.detectedFaces = 0
            for foundFeature in faceFeatures! {
                if foundFeature.type == "Face" {
                    downloadedImage.detectedFaces! += 1
                }
            }
            print("\(NSDate().timeIntervalSince(self.downloadStartTime! as Date)) Face detecting file \(downloadedImage.imageName) finished! Found \(downloadedImage.detectedFaces!) faces.")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return downloadingFiles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "File: \(downloadingFiles[indexPath.row].imageName)"
        cell.detailTextLabel?.text = "Status: \(downloadingFiles[indexPath.row].downloadPercentStatus)%"
        
        if downloadingFiles[indexPath.row].detectedFaces != nil {
            cell.detailTextLabel?.text! += "  Detected faces: \(downloadingFiles[indexPath.row].detectedFaces!)"
        }
        
        if downloadingFiles[indexPath.row].downloadPercentStatus == 100 {
            cell.imageView?.image = downloadingFiles[indexPath.row].image
        }
        
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
