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

        guard let parameters = parameters, let cgContext = (parameters["CGContext"] as! CGContext?) else {return}
        guard let attributes = attributes else { return }
        guard (mode == "pre") else { return }
        
            //there must be a d attributes
        guard let pathString = attributes["d"] else { return }
        
            //find all items in the path
        var instructionsDelimiters = [(Int,String,String)]()
        let delimiters = "mMlLZzHhVvcCqQTtAaSs"
        var oneSubCommand = (0, "", "")
        for (i, c) in pathString.enumerated() {
            if delimiters.contains(c) {
                    //we found significant letter
                if i == 0 {
                    oneSubCommand = (i, String(c), "" )
                } else if c == Character("Z") || c == Character("z") {
                    oneSubCommand = (i, String(c), "" )
                    instructionsDelimiters.append(oneSubCommand)
                    break;
                } else {
                    instructionsDelimiters.append(oneSubCommand)
                    oneSubCommand = (i, String(c), "" )
                }
            } else {
                    //TODO bail on wrong char
                oneSubCommand.2.append(c)
                if i == pathString.count - 1 {
                    instructionsDelimiters.append(oneSubCommand)
                }
            }
           
        }        
        Swift.print(instructionsDelimiters)
            //draw them
        cgContext.beginPath()
        cgContext.setStrokeColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        Swift.print(instructionsDelimiters.count)
        for (_, c) in instructionsDelimiters.enumerated() {
            
            let commandParameters = c.2.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "-", with: " -").split(separator: " ").map({ Double($0)})
            
            
            switch (c.1) {
            case "M":
                cgContext.move(to: CGPoint(x:commandParameters[0]!,y:commandParameters[1]!))
            case "m":
                let currentPoint = cgContext.currentPointOfPath
                cgContext.move(to: CGPoint(x:(commandParameters[0]!+Double(currentPoint.x)),y:(commandParameters[1]!+Double(currentPoint.y))))
            case "C":
                if commandParameters.count % 6 == 0 {
                    for j in 0..<(commandParameters.count/6) {
                        let x = commandParameters[6*j]!
                        let y = commandParameters[6*j+1]!
                        let x1 = commandParameters[6*j+2]!
                        let y1 = commandParameters[6*j+3]!
                        let x2 = commandParameters[6*j+4]!
                        let y2 = commandParameters[6*j+5]!
                        cgContext.addCurve(to: CGPoint(x:x2,y:y2), control1: CGPoint(x:x,y:y), control2: CGPoint(x:x1,y:y1))
                    }
                }
                break;
            case "c":
                
                if commandParameters.count % 6 == 0 {
                    for j in 0..<(commandParameters.count/6) {
                        let currentPoint = cgContext.currentPointOfPath
                        let x = commandParameters[6*j]! + Double(currentPoint.x)
                        let y = commandParameters[6*j+1]! + Double(currentPoint.y)
                        let x1 = commandParameters[6*j+2]! + Double(currentPoint.x)
                        let y1 = commandParameters[6*j+3]! + Double(currentPoint.y)
                        let x2 = commandParameters[6*j+4]! + Double(currentPoint.x)
                        let y2 = commandParameters[6*j+5]! + Double(currentPoint.y)

                        cgContext.addCurve(to: CGPoint(x:x2,y:y2), control1: CGPoint(x:x,y:y), control2: CGPoint(x:x1,y:y1))
                    }
                }
                break;
            case "L":
                cgContext.addLine(to: CGPoint(x:commandParameters[0]!,y:commandParameters[1]!))
                break;
            case "l":
                let currentPoint = cgContext.currentPointOfPath
                cgContext.addLine(to: CGPoint(x:(commandParameters[0]!+Double(currentPoint.x)),y:(commandParameters[1]!+Double(currentPoint.y))))
                break;
            case "s":
                break;
            case "S":
                if commandParameters.count % 4 == 0 {
                }
                break;
            case "Z":
                cgContext.closePath()
            default:
                break;
            }

        }
        
        cgContext.drawPath(using: .stroke)
        
        //let instructions = pathString.split(separator: ["m", "M", "l", "L", "Z", "z", "H", "h", "V", "v"])
        
    }
}
