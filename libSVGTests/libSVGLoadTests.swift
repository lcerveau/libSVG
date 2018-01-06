//
//  libSVGTests.swift
//  libSVGTests
//
//  Created by Laurent Cerveau on 11/3/16.
//  Copyright © 2016 MMyneta. All rights reserved.
//

import XCTest
import Foundation
import clibxml
@testable import libSVG

class libSVGTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadSVGFile() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let testFilePath = URL(fileURLWithPath: #file).appendingPathComponent("../TestFiles/Death.svg").standardizedFileURL.path
        let outFilePath = URL(fileURLWithPath: #file).appendingPathComponent("../Result/testLoad.svg").standardizedFileURL.path

        print("== LOADING:" + testFilePath)
        let svg = SVG(path:testFilePath, options:[.verboseActions])
        svg.dump()
        
        guard let destination:SVGRenderDestination = SVGRenderDestination(destination:outFilePath) else { XCTAssert(false); return}
        svg.addRenderDestination(destination: destination)        
        svg.renderToDestination(destinationUUID: destination.uuid)
    }
    
    func testLoadNonSVGFile() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
