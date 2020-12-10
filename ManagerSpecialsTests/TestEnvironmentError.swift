//
//  TestEnvironmentError.swift
//  ManagerSpecialsTests
//
//  Created by Sean Howell on 12/9/20.
//

import Foundation

enum TestEnvironmentError: Error {
    case resourceNotFound
    case dataNotAvailable
    case viewControllerNotFound
    case datasourceNotAttached
}
