//
//  ViewControllerUnitTests.swift
//  NeverEndingTests
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import XCTest
import SDWebImage
import SwiftyJSON
@testable import NeverEnding

class ViewControllerUnitTests: XCTestCase {
    
    var homeVC: ViewController!
    let urlArray: [String] = ["https://cdn.pixabay.com/photo/2018/07/04/23/17/soap-bubbles-3517247_150.jpg",
                              "https://cdn.pixabay.com/photo/2018/07/04/22/55/fantasy-3517206_150.jpg",
                              "https://cdn.pixabay.com/photo/2018/07/02/22/18/sunflower-3512654_150.jpg",
                              "https://cdn.pixabay.com/photo/2018/07/04/22/55/fantasy-3517206_150.jpg"]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.homeVCStoryboardID) as! ViewController
        _ = homeVC.view
        //homeVC = ViewController(pixlrService: PixlrService(apiURL: ServerConfiguration.apiBaseUrl))
    }
}

// MARK: - Tests for Alert
extension ViewControllerUnitTests {
    func testInValidInputForTextField() {
        performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
            XCTAssertFalse(self.homeVC.checkIfValidInput(), "Empty Input")
        }
    }
    
    func testValidInputForTextField() {
        performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
            self.homeVC.nameTextField.text = "Kamal"
            XCTAssertTrue(self.homeVC.checkIfValidInput(), "Empty Input")
        }
    }
    
    func testIfDidShowValidAlert() {
        performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
            self.homeVC.handleStartClick()
            let exp = self.expectation(description: "Show AlertView Controller on NO Input")
            performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
                // access root view controller
                let root = UIApplication.shared.keyWindow?.rootViewController
                // check if it presented AlertController or not
                XCTAssertTrue(root!.presentedViewController! is UIAlertController)
                // access alertController
                let alertController = root!.presentedViewController as! UIAlertController
                // Check if it has valid title or not
                XCTAssertEqual(alertController.title, Constants.alertTitle)
                // Check if it has valid message or nots
                XCTAssertEqual(alertController.message, Constants.alertMessage)
                // Check if it has valid number of actions or not
                let actions = alertController.actions
                XCTAssertTrue(actions.count == 1)
                // Check if actions has valid titles or not
                XCTAssertEqual(actions[0].title, "OK")
                exp.fulfill()
            }
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }
    
    func testIfDidNotShowAlert() {
        performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
            self.homeVC.nameTextField.text = "Kamal"
            self.homeVC.handleStartClick()
            let exp = self.expectation(description: "No AlertView Controller shown")
            performOperationOnMainAfterDelay(delayTimeInSeconds: 2) {
                // access root view controller
                let root = UIApplication.shared.keyWindow?.rootViewController
                // check if it presented AlertController or not
                XCTAssertFalse(root!.presentedViewController! is UIAlertController)
                exp.fulfill()
            }
            self.waitForExpectations(timeout: 5, handler: nil)
        }
    }
}

// MARK: - Tests for Caching
extension ViewControllerUnitTests {
    func testAddImagesFromCache() {
        SDImageCache.shared().clearDisk(onCompletion: {
            XCTAssertEqual(SDImageCache.shared().getSize(), 0)
            for urlStr in self.urlArray {
                if let imgURL = URL(string: urlStr) {
                    UIImageView().sd_setImage(with: imgURL, completed: { (image, _, _, _) in
                        XCTAssertNotNil(image)
                        XCTAssertGreaterThan(SDImageCache.shared().getSize(), 0)
                    })
                }
            }
        })
    }
}

// MARK: - Tests for Collection View
extension ViewControllerUnitTests {
    func testCollectionViewShouldNotBeNil() {
        XCTAssertNotNil(homeVC.collectionView)
    }
    
    func testCollectionViewDataSourceAndDelegateShouldNotBeNil() {
        XCTAssertNotNil(homeVC.collectionView.dataSource)
        XCTAssertNotNil(homeVC.collectionView.delegate)
    }
    
    func testCollectionViewIsSetAsDelegateAndDataSource() {
        XCTAssertNotNil(homeVC.collectionView.dataSource is ViewController)
        XCTAssertNotNil(homeVC.collectionView.delegate is ViewController)
    }
    
    func testCollectionViewHasSingleDataServiceObject() {
        XCTAssertEqual(homeVC.collectionView.dataSource is ViewController, homeVC.collectionView.delegate is ViewController)
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(homeVC.collectionView.numberOfSections, 1)
        XCTAssertNotEqual(homeVC.collectionView.numberOfSections, 2)
    }
    
    func testNumberOfItemsInSection() {
        homeVC.collectionView.isHidden = false
        
        let dict1: [String: Any] = ["id": 1234, "webformatURL": "https://pixabay.com/get/ea30b0082af4073ed1584d05fb1d4f92eb73ebd01fac104496f0c87ea0efb5be_640.jpg",
                                    "previewURL": urlArray[0]]
        let json1 = JSON(parseJSON: dict1.toJSONString())
        let image1 = PixlrImage(json: json1, pageNumber: 1)
        homeVC.pixlrImageArray.append(image1!)
        
        homeVC.collectionView.reloadData()
        XCTAssertEqual(homeVC.collectionView.numberOfItems(inSection: 0), 1)
        
        let dict2: [String: Any] = ["id": 1234, "webformatURL": "https://pixabay.com/get/ea30b0082af4073ed1584d05fb1d4f92eb73ebd01fac104496f0c87ea0efb5be_640.jpg",
                                    "previewURL": urlArray[1]]
        let json2 = JSON(parseJSON: dict2.toJSONString())
        let image2 = PixlrImage(json: json2, pageNumber: 1)
        homeVC.pixlrImageArray.append(image2!)
        
        homeVC.collectionView.reloadData()
        XCTAssertEqual(homeVC.collectionView.numberOfItems(inSection: 0), 2)
    }
    
    func testCellForItemAtIndexPathReturnsImageCollectionViewCell() {
        homeVC.collectionView.isHidden = false
        
        let dict1: [String: Any] = ["id": 1234, "webformatURL": "https://pixabay.com/get/ea30b0082af4073ed1584d05fb1d4f92eb73ebd01fac104496f0c87ea0efb5be_640.jpg",
                                    "previewURL": urlArray[0]]
        let json1 = JSON(parseJSON: dict1.toJSONString())
        let image1 = PixlrImage(json: json1, pageNumber: 1)
        homeVC.pixlrImageArray.append(image1!)
        
        homeVC.collectionView.reloadData()
        
        let cellQueried = homeVC.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))
        XCTAssertFalse(cellQueried is MockImageCollectionViewCell)
    }
}
