//
//  ManagerSpecialCollectionViewController.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import UIKit

private let reuseIdentifier = "Cell"
private let endPoint = "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/backup"
private let padding: CGFloat = 8

class ManagerSpecialCollectionViewController: UICollectionViewController {

    var canvasPartionCount: CanvasUnit = 1
    var sampleItems = [DiscountItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate Data (TODO: move networking outside of this view controller)
        do {
            let data = try Data(contentsOf: URL(string: endPoint)!)
            
            let decoder = JSONDecoder()
            let endPointResponse = try decoder.decode(EndPointResponse.self, from: data)
            canvasPartionCount = endPointResponse.canvasPartition
            sampleItems = endPointResponse.managerSpecials
        } catch {
            print(error)
        }
        
        // setup the compositional layout
  
        var layoutItems = [NSCollectionLayoutItem]()
        let partitionSize = collectionView.safeAreaLayoutGuide.layoutFrame.width / CGFloat(canvasPartionCount)
        for item in sampleItems { //TODO: use .map()
            let fractionalWidth = partitionSize * CGFloat(item.width)
            let fractionalHeight = partitionSize * CGFloat(item.height)
            let size = NSCollectionLayoutSize(widthDimension: .absolute(fractionalWidth),
                                              heightDimension: .absolute(fractionalHeight))
            let collectionItem = NSCollectionLayoutItem(layoutSize: size)
            collectionItem.contentInsets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
            layoutItems.append(collectionItem)
        }
        var groupedItems: [NSCollectionLayoutGroup] =  buildGroups(from: layoutItems)
       
        
        // center groups
        groupedItems.forEach { (group) in
            group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .flexible(padding), top: nil, trailing: .flexible(padding), bottom: nil)
        }
        
        // apply to section
        guard groupedItems.isEmpty == false else { return }
        let allItemsSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(100))
        let allItemsGroup = NSCollectionLayoutGroup.vertical(layoutSize: allItemsSize, subitems: groupedItems)
        let section = NSCollectionLayoutSection(group: allItemsGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
       
        collectionView.collectionViewLayout = layout
        
        
       
    }
    //    TODO: move this func
    func buildGroups(from items: [NSCollectionLayoutItem]) -> [NSCollectionLayoutGroup] {
        var iterator = items.makeIterator()
        guard let item = iterator.next() else { return [] }
        
        var result = [NSCollectionLayoutGroup]()
        // populate results recursively
        // TODO: rename this func to reflect it populates 'result'
        func buildLayoutItem(for item: NSCollectionLayoutItem) {
            // base case
            guard let nextItem = iterator.next() else {
                // package up item to result
                let size = item.layoutSize
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
                result.append(group)
                return
            }
            
            // TODO: refactor for single call to recurse
            let combinedItemWidth = nextItem.layoutSize.widthDimension.dimension + item.layoutSize.widthDimension.dimension
            if combinedItemWidth <= collectionView.safeAreaLayoutGuide.layoutFrame.width {
                // combine item + nextItem into subgroup and recurse
                let subgroupSize = NSCollectionLayoutSize(widthDimension: .absolute(combinedItemWidth), heightDimension: .estimated(200))
                let subgroup = NSCollectionLayoutGroup.horizontal(layoutSize: subgroupSize, subitems: [item, nextItem])
                buildLayoutItem(for: subgroup)
            } else {
                // reached line break
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: item.layoutSize, subitems: [item])
                result.append(group)
                buildLayoutItem(for: nextItem)
            }
        }
        
        buildLayoutItem(for: item)
        
        
//        result = items
        
        return result
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sampleItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DiscountItemCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DiscountItemCollectionViewCell
        let item = sampleItems[indexPath.row]
        // Configure the cell
        cell.backgroundColor = .cyan
        cell.oldPriceLabel.text = item.originalPrice
        cell.currentPriceLabel.text = item.price
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
