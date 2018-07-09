//
//  PixlrImage.swift
//  NeverEnding
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 Model object for image fetched from Pixlr API
 */
public struct PixlrImage: Equatable {
    public var id: Int
    public var webformatURL: String
    public var previewURL: String
    public var pageNumber: Int
    
    public init?(json: JSON, pageNumber: Int) {
        guard let id = json["id"].int, let webformatURL = json["webformatURL"].string, let previewURL = json["previewURL"].string else {
            return nil
        }
        self.id = id
        self.webformatURL = webformatURL
        self.previewURL = previewURL
        self.pageNumber = pageNumber
    }
}

public func ==(lhs: PixlrImage, rhs: PixlrImage) -> Bool {
    return lhs.id == rhs.id && lhs.webformatURL == rhs.webformatURL && lhs.previewURL == rhs.previewURL && lhs.pageNumber == rhs.pageNumber
}
