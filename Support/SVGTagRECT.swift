//
//  SVGTagSVG.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/01/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import CoreGraphics
import Foundation

class SVGTagRECT:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render RECT")
        
        guard let parameters = parameters, let cgContext = (parameters["CGContext"] as! CGContext?) else {return}
        guard let attributes = attributes else { return }
        guard (mode == "pre") else { return }
        
        //proper rendering
        let w = Double((attributes["width"] ?? "0"))!
        let h = Double((attributes["height"] ?? "0"))!
        let x = Double((attributes["x"] ?? "0"))!
        let y = Double((attributes["y"] ?? "0"))!

        cgContext.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cgContext.beginPath()
        cgContext.addRect(CGRect(x: x, y: y, width: w, height: h))
        cgContext.strokePath()
    }
}
