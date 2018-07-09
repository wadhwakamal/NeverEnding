//
//  PixlrService.swift
//  NeverEnding
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

/**
 PixlrServiceProtocol for Mocking Service
 */
protocol PixlrServiceProtocol {
    func fetchImagesForPage(pageNumber: Int, completionBlock: @escaping (_ response: [PixlrImage]?) -> Void) -> DataRequest?
}

/**
 Handles the API calls and parses the Response
 */
class PixlrService: PixlrServiceProtocol {
    var apiURL: String
    
    init(apiURL: String) {
        self.apiURL = apiURL
    }
    
    @discardableResult
    func fetchImagesForPage(pageNumber: Int, completionBlock: @escaping (_ response: [PixlrImage]?) -> Void) -> DataRequest? {
        let paramDict: [String: String] = [
            "key": Constants.ServerConfiguration.apiKey,
            "image_type": Constants.ServerConfiguration.imageType,
            "page": "\(pageNumber)",
            "per_page": "\(Constants.ServerConfiguration.imagesPerPage)"
        ]
        
        let encodedURLString = Utility.addURLEncoding(apiURL + Utility.generateQueryString(paramDict))
        print(encodedURLString)
        
        return AlamofireConfig.shared.manager.request(encodedURLString)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    let json = JSON(data: response.data!)
                    //print(json)
                    guard json != JSON.null, let hits = json["hits"].array else {
                        completionBlock(nil)
                        return
                    }
                    var pixlrImageArray: [PixlrImage] = []
                    for hit in hits {
                        if let pixlrImage = PixlrImage(json: hit, pageNumber: pageNumber) {
                            pixlrImageArray.append(pixlrImage)
                        }
                    }
                    guard !pixlrImageArray.isEmpty else {
                        completionBlock(nil)
                        return
                    }
                    completionBlock(pixlrImageArray)
                case .failure(_):
                    completionBlock(nil)
                }
        }
    }
}
