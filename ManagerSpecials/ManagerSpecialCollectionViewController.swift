//
//  ManagerSpecialCollectionViewController.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import UIKit
import OSLog

private let reuseIdentifier = "Cell"
private let verticalCellIdentifier = "verticalCell"
private let pictureCellIdentifier = "pictureCell"
private let endPoint = "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/backup"
internal let padding: CGFloat = 4

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
        
        collectionView.collectionViewLayout = setupCollectionLayout(for: sampleItems, width: collectionView.safeAreaLayoutGuide.layoutFrame.width - padding * 2, partitionCount: canvasPartionCount)
       
       
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sampleItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DiscountImageCollectionViewCell
        
        let item = sampleItems[indexPath.row]
        
        // Configure the cell
        cell.backgroundColor = .cyan
        cell.oldPriceLabel?.text = item.originalPrice
        cell.currentPriceLabel?.text = item.price
        cell.displayNameLabel?.text = item.displayName
       
        guard let imageURL = URL(string: item.imageURL) else {
            os_log("imageURL not available")
            return cell
        }
        var request = URLRequest(url: imageURL)
        request.allowsConstrainedNetworkAccess = false
        cell.subscriber = URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let image = UIImage(data: data) else {
                    throw LoadError.invalidResponse
                }
                return image
            })
            .replaceError(with: #imageLiteral(resourceName: "NoPic88"))
            .receive(on: DispatchQueue.main)
            .assign(to: \.imageView.image, on: cell)
        
        return cell
    }
    
    enum LoadError: Error {
        case invalidResponse
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
