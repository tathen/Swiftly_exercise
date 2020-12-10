//
//  DiscountItemTests.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import XCTest
@testable import ManagerSpecials

class DiscountItemTests: XCTestCase {

    func testEquatable() throws {
        let discountItem = DiscountItem(imageURL: "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/images/L.png",
                                        width: 16,
                                        height: 8,
                                        displayName: "Noodle Dish with Roasted Black Bean Sauce",
                                        originalPrice: "2.00",
                                        price: "1.00")
        let firstItem = try TestSamples.endPointResponse().managerSpecials.first
        XCTAssertEqual(firstItem, discountItem)
    }
}
