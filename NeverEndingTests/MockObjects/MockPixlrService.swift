//
//  MockPixlrService.swift
//  NeverEndingTests
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
@testable import NeverEnding

/**
 Reads JSON data from a local file and mocks the API call.
 */
class MockPixlrService: PixlrServiceProtocol {
    var apiURL: String
    
    init(apiURL: String) {
        self.apiURL = apiURL
    }
    
    func fetchImagesForPage(pageNumber: Int, completionBlock: @escaping (_ response: [PixlrImage]?) -> Void) -> DataRequest? {
        
        let bundle = Bundle(for: type(of: self))
        if let path = bundle.path(forResource: "ValidJSONData", ofType: "json") {
            if let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) {
                let json = JSON(data: data)
                guard json != JSON.null, let hits = json["hits"].array else {
                    completionBlock(nil)
                    return nil
                }
                var pixlrImageArray: [PixlrImage] = []
                for hit in hits {
                    if let pixlrImage = PixlrImage(json: hit, pageNumber: pageNumber) {
                        pixlrImageArray.append(pixlrImage)
                    }
                }
                guard !pixlrImageArray.isEmpty else {
                    completionBlock(nil)
                    return nil
                }
                completionBlock(pixlrImageArray)
                return nil
            } else {
                completionBlock(nil)
                return nil
            }
        } else {
            completionBlock(nil)
            return nil
        }
    }
}
