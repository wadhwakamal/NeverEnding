//
//  MockImageCollectionViewCell.swift
//  NeverEndingTests
//
//  Created by Personal on 09/07/18.
//  Copyright © 2018 Kamal Wadhwa. All rights reserved.
//

import Foundation
import UIKit

class MockImageCollectionViewCell: UICollectionViewCell {
    
}

class CollectionViewMock: UICollectionView {
    var cellDequeuedProperly = false
    
    override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        cellDequeuedProperly = true
        return super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
}

