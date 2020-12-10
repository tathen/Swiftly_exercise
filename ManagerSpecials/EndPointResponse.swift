//
//  EndPointResponse.swift
//  ManagerSpecials
//
//  Created by Sean Howell on 12/4/20.
//

import Foundation

class EndPointResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case canvasPartitions = "canvasUnit"
        case managerSpecials
    }
    
    init(partitions: CanvasUnit = 1, specials: [DiscountItem] = []) {
        canvasPartitions = partitions
        managerSpecials = specials
    }
    
    let canvasPartitions: CanvasUnit
    let managerSpecials: [DiscountItem]
}

extension EndPointResponse: Equatable {
    static func == (lhs: EndPointResponse, rhs: EndPointResponse) -> Bool {
        return lhs.canvasPartitions == rhs.canvasPartitions &&
            lhs.managerSpecials == rhs.managerSpecials
    }
    
    
}
