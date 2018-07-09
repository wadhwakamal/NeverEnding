//
//  ViewController.swift
//  NeverEnding
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage
import GSImageViewerController

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    weak var timer: Timer?
    var pixlrService: PixlrServiceProtocol!
    var pixlrImageArray: [PixlrImage] = []
    var footerView: CustomFooterView?
    var isLoading:Bool = false
    var imageSearchRequest: DataRequest?
    var cellHeight: CGFloat?
    
    // MARK:- Initializers
    
    //Inject dependencies
    convenience init(pixlrService: PixlrServiceProtocol) {
        self.init()
        self.pixlrService = pixlrService
    }
    
    // MARK:- DeInitializers
    deinit {
        timer?.invalidate()
    }
    
    // Mark: Actions
    @IBAction func didTapSubmitButton(_ sender: Any) {
        guard checkIfValidInput() else {
            Utility.showAlertMessage(title: Constants.alertTitle, message: Constants.alertMessage, viewController: self)
            return
        }
        
        SVProgressHUD.show(withStatus: Constants.spinnerMessage)
        
        pixlrService.fetchImagesForPage(pageNumber: 1, completionBlock: { [weak self] (pixlrImageArray) in
            SVProgressHUD.dismiss()
            guard let `self` = self, let pixlrImageArray = pixlrImageArray else { return }
            
            self.pixlrImageArray = pixlrImageArray
            self.collectionView.reloadData()
            self.nameLabel.text = self.nameTextField.text
            self.startTimer()
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let `self` = self else { return }
                self.userInputView.alpha = 0
            }
        })
        
        
    }
    
    //Returns true if input is not empty
    func checkIfValidInput() -> Bool {
        guard let name = nameTextField.text, name.isEmpty else {
            return true
        }
        return false
    }
    
    //Refreshes time on UI every 0.05 seconds
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(showDateTime), userInfo: nil, repeats: true)
        if let timer = timer {
            //To avoid lag of timer during scrolling
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
    
    //Shows time value on UI
    @objc func showDateTime() {
        timeLabel.text = Date().toString(with: Constants.dateFormat)
    }
    
    // MARK: UI Methods
    func setupViews() {
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapNameLabel)))
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        //Register FooterView
        collectionView.register(UINib(nibName: Constants.footerViewXibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: Constants.footerViewReuseIdentifier)
        
        //For cell spacing and padding.
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
            layout.minimumInteritemSpacing = 5
            cellHeight = collectionView.frame.size.height / 3
            if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
                layout.itemSize = CGSize(width: (collectionView.frame.size.width - 20) / 2.5, height: collectionView.frame.size.height / 3)
            } else {
                layout.itemSize = CGSize(width: (collectionView.frame.size.width - 20) / 2, height: collectionView.frame.size.height / 3)
            }
        }
    }
    
    @objc func didTapNameLabel() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.userInputView.alpha = 1
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When initialized via Storyboard.
        if pixlrService == nil {
            pixlrService = PixlrService(apiURL: Constants.ServerConfiguration.apiBaseUrl)
        }
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print("Memory Warning Received")
    }
}

// MARK:- UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pixlrImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellReuseIdentifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        imageCell.configureImageCell(pixlrImage: pixlrImageArray[indexPath.row])
        imageCell.deselected()
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let imageCell = cell as? ImageCollectionViewCell else {
            return
        }
        imageCell.selected()
        
        guard let downloadedImage = imageCell.downloadedImage else {
            return
        }
        let imageInfo   = GSImageInfo(image: downloadedImage, imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: imageCell.contentImgView!)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let imageCell = cell as? ImageCollectionViewCell else {
            return
        }
        imageCell.deselected()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoading {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.footerViewReuseIdentifier, for: indexPath) as? CustomFooterView else {
                return UICollectionReusableView()
            }
            self.footerView = footer
            self.footerView?.backgroundColor = UIColor.clear
            return footer
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.footerViewReuseIdentifier, for: indexPath) as? CustomFooterView else {
                return UICollectionReusableView()
            }
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.prepareInitialAnimation()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            self.footerView?.stopAnimate()
        }
    }
    
    //compute the scroll value and play witht the threshold to get desired effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = 100.0
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let diffHeight = contentHeight - contentOffset
        let frameHeight = scrollView.bounds.size.height
        var triggerThreshold = Float((diffHeight - frameHeight))/Float(threshold)
        triggerThreshold = min(triggerThreshold, 0.0)
        let pullRatio = min(fabs(triggerThreshold), 1.0)
        self.footerView?.setTransform(inTransform: CGAffineTransform.identity, scaleFactor: CGFloat(pullRatio))
        if pullRatio >= 1 {
            self.footerView?.animateFinal()
        }
        
        //For memory managament, we free images from top if the infinite list exceeds a certain thresold.
        if let cellHeight = cellHeight, pixlrImageArray.count + Constants.ServerConfiguration.imagesPerPage >= Constants.maxNumberOfImagesAtATime {
            //let top: CGFloat = 0
            let bottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
            let buffer: CGFloat = Constants.cellBuffer * cellHeight
            let scrollPosition = scrollView.contentOffset.y
            
            if scrollPosition > bottom - buffer {
                let tempImagesArray: [PixlrImage] = Array(pixlrImageArray.prefix(Constants.maxNumberOfItemsToBeFreed))
                if tempImagesArray.count > 0 {
                    //print("Reached the bottom of the collection view")
                    pixlrImageArray.removeFirst(Constants.maxNumberOfItemsToBeFreed)
                    // Update the CollectionView and contentOffset
                    collectionView.reloadData()
                    collectionView.contentOffset.y -= CGFloat(Constants.maxNumberOfItemsToBeFreed) * cellHeight
                    removeImagesFromCache(images: tempImagesArray) {
                        
                    }
                }
            } /*else if scrollPosition < top + buffer {
             print("Reach the top of the collection view")
             }*/
        }
    }
    
    func removeImagesFromCache(images: [PixlrImage], completionBlock: @escaping () -> Void) {
        performOperationInBackground {
            //print("Before Clearing: \(SDImageCache.shared().getSize())")
            var count = 0
            for image in images {
                SDImageCache.shared().removeImage(forKey: image.previewURL, fromDisk: true, withCompletion: {
                    count = count + 1
                    if count == images.count {
                        //print("After Clearing: \(SDImageCache.shared().getSize())")
                        completionBlock()
                    }
                })
            }
        }
    }
    
    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (self.footerView?.isAnimatingFinal)! {
            //print("loading more images")
            self.isLoading = true
            self.footerView?.startAnimate()
            
            if let _ = imageSearchRequest {
                //print("Already Ongoing Request")
                return
            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
                var pageNumber = 1 //Default
                if let lastImage = self.pixlrImageArray.last {
                    pageNumber = lastImage.pageNumber + 1
                }
                
                self.imageSearchRequest = self.pixlrService.fetchImagesForPage(pageNumber: pageNumber, completionBlock: { [weak self] (pixlrImageArray) in
                    guard let weakSelf = self else { return }
                    if let pixlrImageArray = pixlrImageArray {
                        weakSelf.pixlrImageArray.append(contentsOf: pixlrImageArray)
                        weakSelf.collectionView.reloadData()
                    } else {
                        //print("No data found")
                        weakSelf.collectionView.scrollToItem(at: IndexPath(row: weakSelf.pixlrImageArray.count - 1, section: 0), at: .bottom, animated: true)
                    }
                    weakSelf.isLoading = false
                    weakSelf.footerView?.stopAnimate()
                    weakSelf.imageSearchRequest = nil
                })
            })
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeypad()
        return false
    }
    
    func hideKeypad() {
        view.endEditing(true)
    }
}
