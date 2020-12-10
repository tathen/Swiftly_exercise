//
//  TestSamples.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import Foundation
import UIKit
@testable import ManagerSpecials

class TestSamples {
    /// A Sample endpont response drawn from SampleData.json
    /// - Throws: An error if unable to find and decode SampleData
    /// - Returns: A sample sutiable for unit tests
    static func endPointResponse() throws -> EndPointResponse {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "SampleData", withExtension: "json") else {
            throw TestEnvironmentError.resourceNotFound
        }
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let endpointResponse = try decoder.decode(EndPointResponse.self, from: jsonData)
            return endpointResponse
            
        } catch {
            throw TestEnvironmentError.dataNotAvailable
        }
    }
    
    /// An instance of the ManagerSpecialCollectionViewController with view already setup and key window
    /// - Throws: An error if ManagerSpecialCollectionViewController not found in storyboard
    /// - Returns: A ManagerSpecialCollectionViewController suitable for testing
    static func managerSpecialCollectionViewController(withLiveTimer isLive: Bool = false) throws -> ManagerSpecialCollectionViewController {
        
        let bundle = Bundle(for: ManagerSpecialCollectionViewController.self)
        let sb = UIStoryboard(name: "Main", bundle: bundle)
        let navigationController = sb.instantiateInitialViewController()
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController = navigationController
        // invoke getter to instantiate the view
        _ = navigationController?.view
        
        guard let managerSpecialVC = navigationController?.children.first as? ManagerSpecialCollectionViewController else {
            throw TestEnvironmentError.viewControllerNotFound
        }
        _ = managerSpecialVC
        
        if isLive {
            return managerSpecialVC
        } else {
            // cancel the data stream and overwrite the discount items
            managerSpecialVC.dataTimer?.cancel()
            let endPointResponse = try! TestSamples.endPointResponse()
            managerSpecialVC.endPointValue = endPointResponse
            managerSpecialVC.discountItems = endPointResponse.managerSpecials
            
            return managerSpecialVC
        }
    }
}
