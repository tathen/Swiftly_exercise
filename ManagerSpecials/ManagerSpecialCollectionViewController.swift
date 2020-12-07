//
//  ManagerSpecialCollectionViewController.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import UIKit
import OSLog
import Combine

// Cell idenitiers
private let fullDetailCellIdentifier = "Cell"
private let verticalCellIdentifier = "verticalCell"
private let pictureCellIdentifier = "pictureCell"
private let longAndShortCellIdentifier = "longAndShortCell"
/// The endpoint URL (Source of Truth)
private let endPoint = "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/backup"
internal let padding: CGFloat = 4
private let priceFontSize: CGFloat = 24
/// The miniumum width required to host cell content with default cell
private let cellWidthCompactThreshold: CGFloat = 160
/// The miniumum height required to host cell content with default cell
private let cellHeightCompactThreshold: CGFloat = 135
private let endPointPollingInterval: TimeInterval = 3

class ManagerSpecialCollectionViewController: UICollectionViewController {

    var endPointValue = EndPointResponse() {
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
    
    /// Fetch the discounted items from the endpoint
    /// - note: Uses a Timer to continously poll the server
    private func fetchDiscountItems() {
        guard let url = URL(string: endPoint) else {
            os_log("Could not make URL from endPoint string")
            return
        }
        dataTimer = Timer.publish(every: endPointPollingInterval, on: RunLoop.main, in: .common)
            .autoconnect()
            .flatMap(maxPublishers: .unlimited) { _  in
                return URLSession.shared.dataTaskPublisher(for: url)
            }
            .assertNoFailure()
            .map(\.data)
            .decode(type: EndPointResponse.self, decoder: JSONDecoder())
            .replaceError(with: EndPointResponse())
            .receive(on: DispatchQueue.main)
            .sink() { endPointResponse in
                if self.endPointValue != endPointResponse {
                    self.endPointValue = endPointResponse
                    self.discountItems = endPointResponse.managerSpecials
                }
            }
    }
    
    private func updateCollectionViewLayout() {
        // indent for padding on both sides completes uniform spacing effect
        let layoutWidth: CGFloat = collectionView.safeAreaLayoutGuide.layoutFrame.width - padding * 2
        collectionView.collectionViewLayout = collectionLayout(for: discountItems, width: layoutWidth, partitionCount: endPointValue.canvasPartitions)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateCollectionViewLayout()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return discountItems.count
    }
    
    func reuseIdentifier(for item:DiscountItem) -> String {
        let partitionPointSize = collectionView.frame.width / CGFloat(endPointValue.canvasPartitions)
        let itemPointWidth = partitionPointSize * CGFloat(item.width)
        let itemPointHeight = partitionPointSize * CGFloat(item.height)
        let reuseIdentifier: String
        let tooNarrow: ClosedRange<CGFloat> = 0...cellWidthCompactThreshold
        let tooShort: ClosedRange<CGFloat> = 0...cellHeightCompactThreshold
        switch (itemPointWidth, itemPointHeight) {
        case (tooNarrow, tooShort):
            reuseIdentifier = pictureCellIdentifier
        case (tooNarrow, _):
            reuseIdentifier = verticalCellIdentifier
        case (_, tooShort):
            reuseIdentifier = longAndShortCellIdentifier
        default:
            reuseIdentifier = fullDetailCellIdentifier
        }
        
        return reuseIdentifier
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = discountItems[indexPath.row]
        let reuseID: String = reuseIdentifier(for: item)
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
    
    // MARK: - Cell Configuration
    
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
    
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "\(item.displayName) was \(item.oldPrice), now \(item.newPrice)"
    }
}
