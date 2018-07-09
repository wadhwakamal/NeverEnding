//
//  ImageCollectionViewCell.swift
//  NeverEnding
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import UIKit
import SDWebImage

/**
 Cell to show the image and asynchronously download it saved in cache.
 */
class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentImgView: UIImageView!
    //var pixlrImage: PixlrImage?
    var downloadedImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addCornerRadius(radius: 5.0)
    }
    
    func configureImageCell(pixlrImage: PixlrImage) {
        //self.pixlrImage = pixlrImage
        if let imageUrl = URL(string: pixlrImage.previewURL) {
            contentImgView.sd_setImage(with: imageUrl, placeholderImage: Constants.placeholderImage, options: [.continueInBackground, .progressiveDownload]) { [weak self] (image, error, type, url) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.downloadedImage = image
            }
        }
    }
    
    func selected() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func deselected() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
    }
}
