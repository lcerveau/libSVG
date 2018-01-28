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
    
    func render(mode:String, parameters: inout [String:Any]?, attributes:[String:String]?){
        
    }
    
    func print(mode:String, parameters: inout [String:Any]?, attributes:[String:String]?){
        
    }
    
    func export(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?){
    
    }
}
