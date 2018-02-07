//
//  SVGTagSVG.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/01/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import CoreGraphics
import Foundation
import ImageIO

class SVGTagG:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render Group")
        if mode == "pre" {
            
        } else if mode == "post" {
            
        }
    }
}
