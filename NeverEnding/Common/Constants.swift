//
//  Constants.swift
//  NeverEnding
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import UIKit

/**
 Defines all constant values to be used in app
 */
struct Constants {
    public static let placeholderImage: UIImage = #imageLiteral(resourceName: "placeholder")
    public static let spinnerMessage = "Please wait..."
    public static let footerViewReuseIdentifier = "RefreshFooterView"
    public static let imageCellReuseIdentifier = "ImageCell"
    public static let dateFormat = "h:mm:ss.SS a"
    public static let alertTitle = "Invalid Entry!"
    public static let alertMessage = "Please enter a name to continue"
    public static let footerViewXibName = "CustomFooterView"
    public static let homeVCStoryboardID = "HomeVC"
    public static let cellBuffer: CGFloat = 6
    public static let maxNumberOfImagesAtATime = 500
    public static let maxNumberOfItemsToBeFreed = ServerConfiguration.imagesPerPage * 5
    
    /**
     Defines all BaseURLs and Configurable parameters
     */
    public struct ServerConfiguration {
        public static let apiKey = "9484956-87df9bae333acc29060cb2e77"
        public static var apiBaseUrl: String = "https://pixabay.com/api"
        public static let imagesPerPage = 20
        public static let imageType = "photo"
    }
}
