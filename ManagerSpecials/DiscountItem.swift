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
    
    let imageURL: String
    let width: CanvasUnit
    let height: CanvasUnit
    let displayName: String
    let originalPrice: String
    let price: String
    
    
}

class EndPointResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case canvasPartition = "canvasUnit"
        case managerSpecials = "managerSpecials"
    }
    
    let canvasPartition: CanvasUnit
    let managerSpecials: [DiscountItem]
}