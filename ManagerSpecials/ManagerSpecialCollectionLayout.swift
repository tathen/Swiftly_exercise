//
//  ManagerSpecialCollectionLayout.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 12/2/20.
//

import Foundation
import UIKit

func buildGroups(from items: [NSCollectionLayoutItem], width: CGFloat) -> [NSCollectionLayoutGroup] {
    var iterator = items.makeIterator()
    guard let item = iterator.next() else { return [] }
    
    var result = [NSCollectionLayoutGroup]()

    /// Uses recursion to build and populate result
    func buildLayoutGroup(for item: NSCollectionLayoutItem) {
        // base case
        guard let nextItem = iterator.next() else {
            // package up item to result
            let size = item.layoutSize
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            result.append(group)
            return
        }
        
        let recursiveArgument: NSCollectionLayoutItem
        let combinedItemWidth = nextItem.layoutSize.widthDimension.dimension + item.layoutSize.widthDimension.dimension
        if combinedItemWidth <= width {
            // combine item + nextItem into subgroup and recurse
            let subgroupSize = NSCollectionLayoutSize(widthDimension: .absolute(combinedItemWidth), heightDimension: .estimated(200))
            let subgroup = NSCollectionLayoutGroup.horizontal(layoutSize: subgroupSize, subitems: [item, nextItem])
            recursiveArgument = subgroup
        } else {
            // reached line break
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: item.layoutSize, subitems: [item])
            result.append(group)
            recursiveArgument = nextItem
        }
        buildLayoutGroup(for: recursiveArgument)
    }
    buildLayoutGroup(for: item)
    
    return result
}

func setupCollectionLayout(for discountItems: [DiscountItem], width: CGFloat, partitionCount: CanvasUnit) -> UICollectionViewLayout {
    var layoutItems = [NSCollectionLayoutItem]()
    let partitionSize = width / CGFloat(partitionCount)
    for item in discountItems { //TODO: use .map()
        let fractionalWidth = partitionSize * CGFloat(item.width)
        let fractionalHeight = partitionSize * CGFloat(item.height)
        let size = NSCollectionLayoutSize(widthDimension: .absolute(fractionalWidth),
                                          heightDimension: .absolute(fractionalHeight))
        let collectionItem = NSCollectionLayoutItem(layoutSize: size)
        collectionItem.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        layoutItems.append(collectionItem)
    }
    let groupedItems: [NSCollectionLayoutGroup] =  buildGroups(from: layoutItems, width: width)
   
    // center groups
    groupedItems.forEach { (group) in
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(padding), top: nil, trailing: .flexible(padding), bottom: nil)
    }
    
    // apply to section
    guard groupedItems.isEmpty == false else { return UICollectionViewLayout() }
    let allItemsSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                           heightDimension: .estimated(100))
    let allItemsGroup = NSCollectionLayoutGroup.vertical(layoutSize: allItemsSize, subitems: groupedItems)
    let section = NSCollectionLayoutSection(group: allItemsGroup)
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
}
