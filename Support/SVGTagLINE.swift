//
//  SVGTagSVG.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/01/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import CoreGraphics
import Foundation

class SVGTagLINE:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render POLYLINE")
        guard let parameters = parameters, let cgContext = (parameters["CGContext"] as! CGContext?) else {return}
        guard let attributes = attributes else { return }
        guard (mode == "pre") else { return }
    }
}
