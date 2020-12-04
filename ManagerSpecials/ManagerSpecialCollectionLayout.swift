//
//  ManagerSpecialCollectionLayout.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 12/2/20.
//

import Foundation
import UIKit

/// Builds and returns groups by combining items that fit width constraint.
/// - Parameters:
///   - items: The set of all collection view items
///   - width: The maximum width of any group
/// - Returns: A collection of groups that fit
func groupedRows(from items: [NSCollectionLayoutItem], width: CGFloat) -> [NSCollectionLayoutGroup] {
    var iterator = items.makeIterator()
    guard let item = iterator.next() else { return [] }
    
    /// A rowGroup is a collection of items that fit horizontally to the width
    var rowGroups = [NSCollectionLayoutGroup]()

    /// Builds and populates rowGroups using recusion and polymorphism
    func buildLayoutGroup(for item: NSCollectionLayoutItem) {
        guard let nextItem = iterator.next() else {
            // base case: exit recursive loop
            let size = item.layoutSize
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            rowGroups.append(group)
            return
        }
        let recursionArgument: NSCollectionLayoutItem
        let combinedItemWidth = nextItem.layoutSize.widthDimension.dimension + item.layoutSize.widthDimension.dimension
        if combinedItemWidth <= width {
            // combine item + nextItem into subgroup and recurse
            let subgroupSize = NSCollectionLayoutSize(widthDimension: .absolute(combinedItemWidth), heightDimension: .estimated(200))
            let subgroup = NSCollectionLayoutGroup.horizontal(layoutSize: subgroupSize, subitems: [item, nextItem])
            recursionArgument = subgroup
        } else {
            // reached line break
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: item.layoutSize, subitems: [item])
            rowGroups.append(group)
            recursionArgument = nextItem
        }
        buildLayoutGroup(for: recursionArgument)
    }
    buildLayoutGroup(for: item)
    
    return rowGroups
}

func collectionLayout(for discountItems: [DiscountItem], width: CGFloat, partitionCount: CanvasUnit) -> UICollectionViewLayout {
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
    let groupedItems: [NSCollectionLayoutGroup] =  groupedRows(from: layoutItems, width: width)
   
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
