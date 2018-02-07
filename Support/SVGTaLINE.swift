//
//  SVGTagSVG.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/01/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import CoreGraphics
import Foundation

class SVGTagPATH:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render PATH")
        if mode == "pre" {
            if let attributes = attributes, let pathString = attributes["d"] {
                Swift.print(pathString)
            }
        } else if mode == "post" {
            
        }
    }
}
