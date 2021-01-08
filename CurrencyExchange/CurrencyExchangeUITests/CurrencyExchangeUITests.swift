//
//  CurrencyExchangeUITests.swift
//  CurrencyExchangeUITests
//
//  Created by sanzrush on 7/1/21.
//

import XCTest
@testable import CurrencyExchange

class CurrencyExchangeUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        
        app = XCUIApplication()
        
    }
    
    func testLabelEmpty() {
        app.launch()
        app.collectionViews.cells.element(boundBy:0).tap()
        let myLabel = app.staticTexts["curLabel"]
        let myTextfield = app.textFields["curText"]
        XCTAssertEqual(myTextfield.value as! String, "1")
        XCTAssertEqual(myLabel.value as! String, "some amount")
        
    }
}
