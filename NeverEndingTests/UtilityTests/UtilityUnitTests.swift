//
//  UtilityUnitTests.swift
//  NeverEndingTests
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import NeverEnding

class UtilityUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testGenerateQueryString() {
        let paramDict: [String: String] = [
            "key": Constants.ServerConfiguration.apiKey,
            "image_type": Constants.ServerConfiguration.imageType,
            "page": "1",
            "per_page": "\(Constants.ServerConfiguration.imagesPerPage)"
        ]
        let queryString = Constants.ServerConfiguration.apiBaseUrl + Utility.generateQueryString(paramDict)
        XCTAssertEqual(queryString, "https://pixabay.com/api?page=1&per_page=20&key=9484956-87df9bae333acc29060cb2e77&image_type=photo")
    }
    
    func testURLEncodingString() {
        let queryString = "https://pixabay.com/api?page=1&per_page=20&key=9484956-87df9bae333acc29060cb2e77& image_type=photo"
        let urlEncodedString = Utility.addURLEncoding(queryString)
        XCTAssertEqual(urlEncodedString, "https://pixabay.com/api?page=1&per_page=20&key=9484956-87df9bae333acc29060cb2e77&%20image_type=photo")
    }
    
    func testDictionarytoJSONString() {
        let dict: [String: Any] = ["key1": 1234, "key2": "Hello"]
        let jsonString = dict.toJSONString()
        XCTAssertNotEqual(jsonString, "Not a valid JSON")
        let json = JSON(parseJSON: jsonString)
        
        XCTAssertEqual(json["key1"].int, dict["key1"] as? Int)
        XCTAssertEqual(json["key2"].string, dict["key2"] as? String)
    }
}
