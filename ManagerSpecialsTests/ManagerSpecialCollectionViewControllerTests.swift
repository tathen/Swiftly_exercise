//
//  ManagerSpecialCollectionViewControllerTests.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import XCTest
@testable import ManagerSpecials

class ManagerSpecialCollectionViewControllerTests: XCTestCase {

    var managerSpecialCollectionVC: ManagerSpecialCollectionViewController!
    var collectionView: UICollectionView! {
        managerSpecialCollectionVC.collectionView
    }
    var firstCell: DiscountImageCollectionViewCell {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        
        return managerSpecialCollectionVC.collectionView.dataSource?.collectionView(collectionView, cellForItemAt: firstIndexPath) as! DiscountImageCollectionViewCell
    }
    var lastCell: DiscountImageCollectionViewCell {
        let lastIndexPath = IndexPath(item: managerSpecialCollectionVC.discountItems.count - 1, section: 0)
        
        return managerSpecialCollectionVC.collectionView.dataSource?.collectionView(collectionView, cellForItemAt: lastIndexPath) as! DiscountImageCollectionViewCell
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let managerSpecialVC = try TestSamples.sampleManagerSpecialCollectionViewController()
        // cancel the data stream and overwrite the discount items
        managerSpecialVC.dataTimer?.cancel()
        let endPointResponse = try! TestSamples.sampleEndPointResponse()
        managerSpecialVC.endPointValue = endPointResponse
        managerSpecialVC.discountItems = endPointResponse.managerSpecials
        managerSpecialCollectionVC = managerSpecialVC
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDataSourceSetup() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        guard let _ = managerSpecialCollectionVC.collectionView.dataSource else {
            throw TestEnvironmentError.datasourceNotAttached
        }
        guard let collectionView = managerSpecialCollectionVC.collectionView else {
            throw TestEnvironmentError.viewControllerNotFound
        }
        XCTAssert(collectionView.collectionViewLayout is UICollectionViewCompositionalLayout)
        collectionView.layoutIfNeeded()
        
        //Inspect first cell
        XCTAssertNotNil(firstCell.subscriber)
        XCTAssertEqual(firstCell.currentPriceLabel?.text, "$1.00")
        XCTAssertEqual(firstCell.oldPriceLabel?.text, "$2.00")
        XCTAssertEqual(firstCell.displayNameLabel?.text, "Noodle Dish with Roasted Black Bean Sauce")
        // test decorate(_:) (regression test) 
        XCTAssertEqual(firstCell.contentView.layer.cornerRadius, 10)
        XCTAssertEqual(firstCell.contentView.layer.masksToBounds, true)
        XCTAssertEqual(firstCell.contentView.backgroundColor, .white)
        XCTAssertEqual(firstCell.layer.shadowColor, UIColor.gray.cgColor)
        XCTAssertEqual(firstCell.layer.shadowOffset, CGSize(width: 0, height: 2.0))
        XCTAssertEqual(firstCell.layer.shadowRadius, 8)
        XCTAssertEqual(firstCell.layer.shadowOpacity, 0.5)
        XCTAssertEqual(firstCell.layer.masksToBounds, false)
        
    }
    
    /// Regression test of endpoint
    func testURL() {
        let url = ManagerSpecialCollectionViewController.endPontURL
        XCTAssertNotNil(url)
        XCTAssertEqual(url, URL(string: "https://raw.githubusercontent.com/Swiftly-Systems/code-exercise-ios/master/backup"))
    }
}
