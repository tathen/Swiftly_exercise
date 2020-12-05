//
//  EndPointResponse.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 12/4/20.
//

import Foundation

class EndPointResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case canvasPartition = "canvasUnit"
        case managerSpecials
    }
    
    init() {
        canvasPartition = 1
        managerSpecials = []
    }
    
    let canvasPartition: CanvasUnit
    let managerSpecials: [DiscountItem]
}

