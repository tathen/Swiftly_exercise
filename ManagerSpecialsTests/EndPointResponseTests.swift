//
//  EndPointResponseTests.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import XCTest
@testable import ManagerSpecials
class EndPointResponseTests: XCTestCase {

    func testEquatable() throws {
        let basicEndPoint = EndPointResponse()
        let defaultValuesEndPoint = EndPointResponse(partitions: 1, specials: [])
        XCTAssertEqual(basicEndPoint, defaultValuesEndPoint)
        
       
    }
}
