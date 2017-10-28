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
    let tag:SVGTag
    let content:String?
    let attributes:[String:Any]?
    
    //Move to a init? anc check tag
    init(tag:SVGTag, attributes:[String:Any]? = nil) {
        self.tag = tag
        self.attributes = (nil == attributes) ? [String:Any]() : attributes!
        self.content = ""
    }
}
