//
//  SwiftTestCodeGeneratorTests.swift
//  CapriccioLibTests
//
//  Created by Franco on 03/09/2018.
//

import XCTest
import Foundation
import Nimble
import Gherkin
@testable import CapriccioLib

final class SwiftTestCodeGeneratorTests: XCTestCase {
    var swiftCodeGenerator: SwiftTestCodeGenerator!
    
    override func setUp() {
        super.setUp()
        swiftCodeGenerator = SwiftTestCodeGenerator()
    }
    
    override func tearDown() {
        swiftCodeGenerator = nil
        super.tearDown()
    }
    
    func testItUsesTheGeneratedClassType() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: TestClass {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                Then("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult, generatedClassType: "TestClass")
    }
    
    func testItRemovesNotAllowedCaracters() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .then, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                Then("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult)
    }
    
    func testItChangesButToAnd() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                And("Something else happens")
            }
        }
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult)
    }
    
    func testItDisablesFileLenghtWarningWhenRequired() {
        let scenario: Scenario = .simple(ScenarioSimple(name: "Scenario \\/ I want to test",
                                                        description: "",
                                                        steps:[Step(name: .given, text: "I'm in a situation"),
                                                               Step(name: .when, text: "Something happens"),
                                                               Step(name: .but, text: "Something else happens")] ))
        let feature = Feature(name: "Feature $%^& number one",
                              description: "",
                              scenarios: [scenario])
        
        let expectedResult = """
        import XCTest
        import XCTest_Gherkin

        // swiftlint:disable file_length
        final class FeatureNumberOne: XCTestCase {
            func testScenarioIWantToTest() {
                Given("I'm in a situation")
                When("Something happens")
                And("Something else happens")
            }
        }
        // swiftlint:enable file_length
        """
        
        fileGenerationCheck(feature: feature, expectedResult: expectedResult, disableFileLenghtWarning: true)
    }
    
    func fileGenerationCheck(feature: Feature, expectedResult: String, generatedClassType: String? = nil, disableFileLenghtWarning: Bool = false) {
        let text = swiftCodeGenerator.generateSwiftTestCode(forFeature: feature, generatedClassType: generatedClassType, disableFileLenghtWarning: disableFileLenghtWarning)
        expect(self.splittedAndTrimmedStringToTest(fromString: expectedResult)) == splittedAndTrimmedStringToTest(fromString: text)
    }
    
    /// Stencil generates files with a lot of newlines and spaces depending on how is the stancil file written, given the important part to test is the actual generated text instead of the number of newlines and whitespaces, the string is splitted to take just the not empty lines and trimmed to remove the whitespaces
    private func splittedAndTrimmedStringToTest(fromString string: String) -> [String] {
        return string.split(separator: "\n", omittingEmptySubsequences: true).compactMap { let result = String($0).trim(); return result.isEmpty ? nil : result  }
    }
}

fileprivate extension String {
    fileprivate func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
