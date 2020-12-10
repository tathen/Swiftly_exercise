//
//  ManagerSpecialsCollectionLayoutTests.swift
//  ManagerSpecialsCollectionLayoutTests
//
//  Created by Sean Howell on 11/30/20.
//

import XCTest
@testable import ManagerSpecials

class ManagerSpecialsCollectionLayoutTests: XCTestCase {

    
    var discountItems: [DiscountItem]!
    var canvasPartitionCount: CanvasUnit!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let endPointResponse = try TestSamples.sampleEndPointResponse()
        discountItems = endPointResponse.managerSpecials
        canvasPartitionCount = endPointResponse.canvasPartitions
    }

    func testSetup() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertNotNil(discountItems)
        XCTAssertEqual(discountItems.count, 6)
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
        XCTAssertEqual(noWidth.count, 6)
        
        let groups = groupedRows(from: layoutItems, width: testWidth)
        XCTAssertEqual(groups.count, 3)
    }

    //collectionLayout(for discountItems: [DiscountItem], width: CGFloat, partitionCount: CanvasUnit) -> UICollectionViewLayout
    func testCollectionLayoutForDiscountItems() {
        //TODO: remove useless test, replace with integration test in ViewController
//        let testWidth: CGFloat = 1000
//        let noItemLayout = collectionLayout(for: [], width: testWidth, partitionCount: canvasPartitionCount)
//        XCTAssertFalse(noItemLayout is UICollectionViewCompositionalLayout)
//
//        let layout = collectionLayout(for: discountItems, width: testWidth, partitionCount: canvasPartitionCount)
//        XCTAssert(layout is UICollectionViewCompositionalLayout)
//        let compLayout = layout as! UICollectionViewCompositionalLayout
    }
}
