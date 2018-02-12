//
//  SVGTagSVG.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/01/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import CoreGraphics
import Foundation

class SVGTagCIRCLE:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render CIRCLE")

        guard let parameters = parameters, let cgContext = (parameters["CGContext"] as! CGContext?) else {return}
        guard let attributes = attributes else { return }
        guard (mode == "pre") else { return }

        //proper rendering
        let cx = CGFloat(Double((attributes["cx"] ?? "0"))!)
        let cy = CGFloat(Double((attributes["cy"] ?? "0"))!)
        let r = CGFloat(Double((attributes["r"] ?? "0"))!)
        
        cgContext.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        cgContext.beginPath()
        cgContext.addArc(center: CGPoint(x:cx, y:cy), radius: r, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        cgContext.strokePath()

        
        
    }
}
