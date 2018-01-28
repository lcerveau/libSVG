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
import libSVG

class SVGTagSVG:SVGElement {
    override func render(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?) {
        Swift.print("render SVG")
        //guard let
        var x = 0, y = 0, w = 0, h = 0
        
        if let viewBoxString =  attributes!["viewBox"] {
            let portComponents = viewBoxString.split(separator:" ")
            x = Int(portComponents[0])!
            y = Int(portComponents[1])!
            w = Int(portComponents[2])!
            h = Int(portComponents[3])!
        }
        
        if mode == "pre" {
                //this is true only in case of file
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            let cgContext = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            parameters!["CGContext"] = cgContext
        } else if mode == "post" {
            let cgContext = (parameters!["CGContext"]) as! CGContext
            let svgDestination = ((parameters!["destination"]) as! SVGRenderDestination)
            if let image = cgContext.makeImage() {
                CGImageDestinationAddImage((svgDestination.imageIODestination)!, image, nil )
                CGImageDestinationFinalize((svgDestination.imageIODestination)!)
            }
            
        }
    }
}
