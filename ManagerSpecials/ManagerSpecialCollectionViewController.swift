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
private let pollingInterval: TimeInterval = 3

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDiscountItems()
    }
    
    /// Fetch the items to populate canvsePartitionCount and discountItems
    private func fetchDiscountItems() {
        guard let url = URL(string: endPoint) else {
            os_log("Could not make URL from endPoint string")
            return
        }
        dataTimer = Timer.publish(every: pollingInterval, on: RunLoop.main, in: .common)
            .autoconnect()
            .flatMap(maxPublishers: .unlimited) { _  -> URLSession.DataTaskPublisher in
                return URLSession.shared.dataTaskPublisher(for: url)
            }
            .assertNoFailure()
            .map(\.data)
            .decode(type: EndPointResponse.self, decoder: JSONDecoder())
            .replaceError(with: EndPointResponse())
            .receive(on: DispatchQueue.main)
            .sink() { endPointResponse in
                print("check endpoint: \(endPointResponse.managerSpecials.count)")
                if self.canvasPartionCount != endPointResponse.canvasPartition {
                    self.canvasPartionCount = endPointResponse.canvasPartition
                }
                if self.discountItems != endPointResponse.managerSpecials {
                    self.discountItems = endPointResponse.managerSpecials
                }
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
        case malformedData
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
