//
//  CollectionViewFlowLayoutCenterItem.swift
//  Music
//
//  Created by Aleksandr on 04.05.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class CollectionViewFlowLayoutCenterItem: UICollectionViewFlowLayout {

    public var centerItemEnabled = false

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard centerItemEnabled == true else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        if let cv = self.collectionView {
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5;
            let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;

            if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
                var candidateAttributes : UICollectionViewLayoutAttributes?

                for attributes in attributesForVisibleCells {
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionElementCategory.cell {
                        continue
                    }

                    if let candAttrs = candidateAttributes {
                        let a = attributes.center.x - proposedContentOffsetCenterX
                        let b = candAttrs.center.x - proposedContentOffsetCenterX

                        if fabsf(Float(a)) < fabsf(Float(b)) {
                            candidateAttributes = attributes;
                        }
                    } else {
                        // == First time in the loop == //
                        candidateAttributes = attributes;
                        continue;
                    }
                }

                return CGPoint(x : candidateAttributes!.center.x - halfWidth, y : proposedContentOffset.y);
            }
        }

        // Fallback
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
}
