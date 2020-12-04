//
//  ManagerSpecialCollectionViewController.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import UIKit
import OSLog
import Combine

private let fullDetailCellIdentifier = "Cell"
private let verticalCellIdentifier = "verticalCell"
private let pictureCellIdentifier = "pictureCell"
private let longAndShortCellIdentifier = "longAndShortCell"
private let endPoint = "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/backup"
internal let padding: CGFloat = 4
private let priceFontSize: CGFloat = 24

class ManagerSpecialCollectionViewController: UICollectionViewController {

    var canvasPartionCount: CanvasUnit = 1 {
        didSet {
            updateCollectionViewLayout()
        }
    }
    var discountItems = [DiscountItem]() {
        didSet {
            updateCollectionViewLayout()
        }
    }
    var dataTimer: AnyCancellable?
    var itemLoader: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDiscountItems()
    }
    
    /// Fetch the items to populate canvseePartitionCount and discountItems
    private func fetchDiscountItems() {
        //        dataTimer = Timer.publish(every: 5, on: RunLoop.main, in: .common)
        //            .autoconnect()
        //            .sink() { [weak self] _ in
        //
        //            }
        
        guard let url = URL(string: endPoint) else {
            os_log("Could not make URL from endPoint")
            return
        }
        itemLoader = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { data, response -> EndPointResponse in
                let decoder = JSONDecoder()
                do {
                    let endPointResponse = try decoder.decode(EndPointResponse.self, from: data)
                    return endPointResponse
                } catch {
                    throw LoadError.illformedData
                }
            }
            .receive(on: DispatchQueue.main)
            .assertNoFailure() // if the data can't be used, this app should just crash
            .sink() { endPointResponse in
                self.canvasPartionCount = endPointResponse.canvasPartition
                self.discountItems = endPointResponse.managerSpecials
            }
        
    }
    
    private func updateCollectionViewLayout() {
        // indent for padding on both sides completes layout illusion
        let layoutWidth: CGFloat = collectionView.safeAreaLayoutGuide.layoutFrame.width - padding * 2
        collectionView.collectionViewLayout = collectionLayout(for: discountItems, width: layoutWidth, partitionCount: canvasPartionCount)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateCollectionViewLayout()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discountItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = discountItems[indexPath.row]
        let reuseID: String
        switch (item.width, item.height) {
        case (0...3, _):
            fallthrough
        case (4...5, 0...5):
            reuseID = pictureCellIdentifier
        case (4...5, _):
            reuseID = verticalCellIdentifier
        case (_, 0...4):
            reuseID = longAndShortCellIdentifier
        default:
            reuseID = fullDetailCellIdentifier
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! DiscountImageCollectionViewCell
        
        // Configure the cell
        decorate(cell: cell)
        populateContenst(of: cell, with: item)

        return cell
    }
    
    enum LoadError: Error {
        case invalidResponse
        case illformedData
    }
    
    /// Apply color, shadow, and corner radius to the cell
    /// - Parameter cell: The cell to decorate
    func decorate(cell: UICollectionViewCell) {
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.contentView.backgroundColor = .white
        
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 8
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
    }
    
    /// Populate the labels and images
    /// - Parameters:
    ///   - cell: The cell to populate
    ///   - item: The discounted item
    func populateContenst(of cell: DiscountImageCollectionViewCell, with item: DiscountItem) {
        cell.oldPriceLabel?.text = item.oldPrice
        let attributesDict: [NSAttributedString.Key : Any] = [NSAttributedString.Key.strikethroughStyle : 2,
                              NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: priceFontSize)]
        let attributedOldPrice = NSAttributedString(string: item.oldPrice, attributes: attributesDict)
        cell.oldPriceLabel?.attributedText = attributedOldPrice
        
        cell.currentPriceLabel?.text = item.newPrice
        cell.currentPriceLabel?.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        cell.currentPriceLabel?.font = UIFont.boldSystemFont(ofSize: priceFontSize)
        cell.displayNameLabel?.text = item.displayName
        guard let imageURL = URL(string: item.imageURL) else {
            os_log("imageURL not available")
            return
        }
        let request = URLRequest(url: imageURL)
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
    }
}
