//
//  DiscountItem.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 11/30/20.
//

import Foundation

typealias CanvasUnit = Int

class DiscountItem : Codable {
    enum CodingKeys: String, CodingKey {
        case imageURL = "imageUrl"
        case width
        case height
        case displayName = "display_name"
        case originalPrice = "original_price"
        case price
    }
    
    init(imageURL: String,
         width: CanvasUnit,
         height: CanvasUnit,
         displayName: String,
         originalPrice: String,
         price: String) {
        self.imageURL = imageURL
        self.width = width
        self.height = height
        self.displayName = displayName
        self.originalPrice = originalPrice
        self.price = price
    }
    
    let imageURL: String
    let width: CanvasUnit
    let height: CanvasUnit
    let displayName: String
    let originalPrice: String
    let price: String
}

extension DiscountItem {
    var oldPrice: String {
        "$\(originalPrice)"
    }
    
    var newPrice: String {
        "$\(price)"
    }
}

extension DiscountItem: Equatable {
    static func == (lhs: DiscountItem, rhs: DiscountItem) -> Bool {
        return lhs.imageURL == rhs.imageURL &&
            lhs.width == rhs.width &&
            lhs.height == rhs.height &&
            lhs.displayName == rhs.displayName &&
            lhs.originalPrice == rhs.originalPrice &&
            lhs.price == rhs.price
    }
}
