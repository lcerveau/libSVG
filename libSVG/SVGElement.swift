//
//  Element.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/19/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation
import clibxml

class SVGElement {
    let tag:String
    let type:String
    let content:String
    let attributes:[String:Any]?
    
    //Move to a init? anc check tag
    init(tag:String, attributes:[String:Any]?) {
        self.tag = tag
        self.type = "lala"
        self.attributes = (nil == attributes) ? [String:Any]() : attributes
        self.attributes = (nil == attributes) ? [String:Any]() : attributes
    }
}
