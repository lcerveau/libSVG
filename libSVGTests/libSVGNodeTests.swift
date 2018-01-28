
//
//  libSVGNodeTest.swift
//  libSVGTests
//
//  Created by Laurent Cerveau on 01/27/2018.
//  Copyright © 2018 MMyneta. All rights reserved.
//

import XCTest
import clibxml
@testable import libSVG


class libSVGNodeTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testManipulateNode() {
        //Create a Node add three children (on with children), in three different way, remove a
        let node = SVGNode()
        XCTAssertTrue(node.children.count == 0)
        XCTAssertTrue(node.treeIdentifier == "0")
        XCTAssertTrue(node.height() == 1)
        
        //Addition through init with parent
        let childNode1 = SVGNode(parentNode:node)
        XCTAssertTrue(node.children.count == 1)
        XCTAssertTrue(childNode1.treeIdentifier == "00")
        print(childNode1.treeIdentifier)
        XCTAssertTrue(node.height() == 2)
        
        //Addition through append
        let childNode2 = SVGNode()
        node.appendChild(childNode: childNode2)
        XCTAssertTrue(node.children.count == 2)
        XCTAssertTrue(childNode1.treeIdentifier == "00")
        XCTAssertTrue(childNode2.treeIdentifier == "01")
        XCTAssertTrue(node.height() == 2)
        
        //Addition through insert
        let childNode3 = SVGNode()
        let childNode4 = SVGNode(parentNode:childNode3)
        let childNode5 = SVGNode(parentNode:childNode3)
        XCTAssertTrue(childNode4.treeIdentifier == "00")
        XCTAssertTrue(childNode5.treeIdentifier == "01")
        node.insertChild(childNode: childNode3, at: 1)
        XCTAssertTrue(node.children.count == 3)
        XCTAssertTrue(node.height() == 3)
        XCTAssertTrue(childNode1.treeIdentifier == "00")
        XCTAssertTrue(childNode3.treeIdentifier == "01")
        XCTAssertTrue(childNode2.treeIdentifier == "02")
        XCTAssertTrue(childNode4.treeIdentifier == "010")
        XCTAssertTrue(childNode5.treeIdentifier == "011")        
    }

}
