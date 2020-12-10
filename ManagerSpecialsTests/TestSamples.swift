//
//  TestSamples.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import Foundation
@testable import ManagerSpecials

class TestSamples {
    static func sampleEndPointResponse() throws -> EndPointResponse {
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
}
