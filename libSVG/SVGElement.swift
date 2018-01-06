//
//  Element.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/19/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation
import clibxml

class SVGElement:SVGTagInstance {
    let tag:SVGTag
    var content:String?
    var attributes:[String:String]?
    
    //Move to a init? anc check tag
    init(tag:SVGTag, attributes:[String:String]? = nil) {
        self.tag = tag
        self.attributes = (nil == attributes) ? [String:String]() : attributes!
        self.content = ""
    }
    
    func addAttribute(key:String, value:String) {
        //test the fact that a tag accept an attribute
        self.attributes![key] = value
    }
    
        //Main instance does nothing
    func render(context:inout CGContext?, attributes:[String:Any]?) {
        
    }
}
