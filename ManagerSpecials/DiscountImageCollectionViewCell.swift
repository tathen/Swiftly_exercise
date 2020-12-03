//
//  DiscountItemCollectionViewCell.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import UIKit
import Combine

class DiscountImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var oldPriceLabel: UILabel?
    @IBOutlet weak var currentPriceLabel: UILabel?
    @IBOutlet weak var displayNameLabel: UILabel?
    
    var subscriber: AnyCancellable?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriber?.cancel()
    }
}

