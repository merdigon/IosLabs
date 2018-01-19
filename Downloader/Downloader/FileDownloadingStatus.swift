//
//  FileDownloadingStatus.swift
//  ImageDownloader
//
//  Created by merdigon on 18/01/2018.
//  Copyright © 2018 merdigon. All rights reserved.
//

import Foundation
import UIKit

class FileDownloadingStatus {
    var imageName: String = ""
    var downloadPercentStatus: Double = 0.0
    var image: UIImage?
    var imageUrl: String = ""
    var detectedFaces: Int?
    var fiftyPercentStageWasLogged = false
}
