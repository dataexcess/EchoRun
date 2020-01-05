//
//  CollectionFlowLayout.swift
//  innate
//
//  Created by dataexcess on 05.01.20.
//  Copyright © 2020 dataexcess. All rights reserved.
//

import UIKit

class CollectionFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        sectionInset = .zero
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x
        let targetRect = CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0), size: self.collectionView!.bounds.size)
        for layoutAttributes in super.layoutAttributesForElements(in: targetRect)! {
            let itemOffset = layoutAttributes.frame.origin.x
            if (abs(itemOffset - horizontalOffset) < abs(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        }
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
