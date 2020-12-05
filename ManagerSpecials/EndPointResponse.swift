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
    
    init() {
        canvasPartitions = 1
        managerSpecials = []
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
