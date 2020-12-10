//
//  ManagerSpecialsCollectionLayoutTests.swift
//  ManagerSpecialsCollectionLayoutTests
//
//  Created by Sean Howell on 11/30/20.
//

import XCTest
@testable import ManagerSpecials

class ManagerSpecialsCollectionLayoutTests: XCTestCase {

    enum TestEnvironementError: Error {
        case resourceNotFound
        case dataNotAvailable
    }
    
    var discountItems: [DiscountItem]!
    var canvasPartitionCount: CanvasUnit!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "SampleData", withExtension: "json") else {
            throw TestEnvironementError.resourceNotFound
        }
        do {
           let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let endpointResponse = try decoder.decode(EndPointResponse.self, from: jsonData)
            canvasPartitionCount = endpointResponse.canvasPartitions
            discountItems = endpointResponse.managerSpecials
        } catch {
            throw TestEnvironementError.dataNotAvailable
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetup() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(discountItems)
        XCTAssertEqual(discountItems.count, 3)
        XCTAssertNotNil(canvasPartitionCount)
        XCTAssertEqual(canvasPartitionCount, 16)
    }

    func testGroupedRowsFromItems() {
        let testWidth: CGFloat = 820
        let noGroups = groupedRows(from: [], width: testWidth)
        XCTAssert(noGroups.isEmpty)
        let layoutItems = discountItems.map {
            layoutItem(for: $0, canvasUnitPointSize: testWidth / CGFloat(canvasPartitionCount))
        }
        
        // instant line breaks will cause each item to be grouped individually
        let noWidth = groupedRows(from: layoutItems, width: 0)
        XCTAssertEqual(noWidth.count, 3)
        
        let groups = groupedRows(from: layoutItems, width: testWidth)
        XCTAssertEqual(groups.count, 2)
    }

    //collectionLayout(for discountItems: [DiscountItem], width: CGFloat, partitionCount: CanvasUnit) -> UICollectionViewLayout
    func testCollectionLayoutForDiscountItems() {
        let testWidth: CGFloat = 1000
        let noItemLayout = collectionLayout(for: [], width: testWidth, partitionCount: canvasPartitionCount)
        XCTAssertFalse(noItemLayout is UICollectionViewCompositionalLayout)
     
        let layout = collectionLayout(for: discountItems, width: testWidth, partitionCount: canvasPartitionCount)
        XCTAssert(layout is UICollectionViewCompositionalLayout)
      
    }
}
