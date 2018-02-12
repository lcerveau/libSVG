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
        var pathInstructions = [(index:Int,command:String,parameterString:String)]()
        let delimiters = "mMlLZzHhVvcCqQTtAaSs"
        let digits = "0123456789"
        let separators = "-,. "
        var lastSeparator=""
        var oneInstruction = (index:0, command:"", parameterString:"")
        for (i, c) in pathString.enumerated() {
            if delimiters.contains(c) {
                    //we found significant letter
                lastSeparator = ""
                if i == 0 {
                    oneInstruction = (i, String(c), "" )
                } else if c == Character("Z") || c == Character("z") {
                    pathInstructions.append(oneInstruction)
                    oneInstruction = (i, String(c), "" )
                    pathInstructions.append(oneInstruction)
                    break; //TODO no need to break there can be other
                } else {
                    pathInstructions.append(oneInstruction)
                    oneInstruction = (i, String(c), "" )
                }
            } else if digits.contains(c){
                oneInstruction.parameterString.append(c)
                if i == pathString.count - 1 {
                    pathInstructions.append(oneInstruction)
                }
            } else if separators.contains(c){
                switch c {
                case " ",",":
                    oneInstruction.parameterString.append(" ")
                case "-":
                    let previousChar = pathString[pathString.index(pathString.startIndex, offsetBy:i-1)]
                    if delimiters.contains(previousChar) == false && previousChar != " " {
                        oneInstruction.parameterString.append(" -")
                    } else {
                        oneInstruction.parameterString.append("-")
                    }
                case ".":
                    let previousChar = pathString[pathString.index(pathString.startIndex, offsetBy:i-1)]
                    if lastSeparator == "." {
                        oneInstruction.parameterString.append(" 0.")
                    } else if previousChar == "-" {
                        oneInstruction.parameterString.append("0.")
                    } else {
                        oneInstruction.parameterString.append(c)
                    }
                    break
                default:
                    break;
                }
                lastSeparator = String(c)
                
                if i == pathString.count - 1 {
                    pathInstructions.append(oneInstruction)
                }
            } else {
                Swift.print("Invalid character in <path d>:ignoring ")
            }
           
        }
        
            //draw them
        cgContext.beginPath()
        cgContext.setStrokeColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)

        for (i, c) in pathInstructions.enumerated() {
                //get instruction parameters
            let ips = c.parameterString.split(separator: " ").map( { CGFloat(Double($0)!) })
            
            switch (c.command) {
            case "M", "m":
                if ips.count % 2 != 0 { break }
                for j in 0..<(ips.count/2) {
                    let cp = cgContext.currentPointOfPath
                    let (cpx, cpy)  = (c.command == "m") ? (cp.x, cp.y) : (0.0, 0.0)
                    cgContext.move(to: CGPoint(x:ips[2*j]+cpx,y:ips[2*j+1]+cpy))
                }
            case "C", "c":
                if ips.count % 6 != 0 { break }
                for j in 0..<(ips.count/6) {
                    let cp = cgContext.currentPointOfPath
                    let (cpx, cpy)  = (c.command == "c") ? (cp.x, cp.y) : (0.0, 0.0)
                    let ctrlPoint1 = CGPoint(x:ips[6*j]+cpx, y:ips[6*j+1]+cpy)
                    let ctrlPoint2 = CGPoint(x:ips[6*j+2]+cpx, y:ips[6*j+3]+cpy)
                    let endPoint = CGPoint(x:ips[6*j+4]+cpx, y:ips[6*j+5]+cpy)
                    cgContext.addCurve(to: endPoint, control1: ctrlPoint1, control2: ctrlPoint2)
                }
                break;
            case "L", "l":
                if ips.count % 2 != 0 { return }
                for j in 0..<(ips.count/2) {
                    let cp = cgContext.currentPointOfPath
                    let (cpx, cpy)  = (c.command == "l") ? (cp.x, cp.y) : (0.0, 0.0)
                    cgContext.addLine(to: CGPoint(x:(ips[2*j]+cpx),y:(ips[2*j+1]+cpy)))
                }
                break;
            case "S", "s":
                if i == 0 { return }
                if ips.count % 4 != 0 { return }
                let previousInstruction = pathInstructions[i-1]
                
                    //TODO check what happens if not one of those like a Q?
                if !( ["S", "s", "C", "c"].contains(previousInstruction.command) ) { return }
                let previousParameters = previousInstruction.parameterString.split(separator: " ").map( { CGFloat(Double($0)!) })
                
                for j in 0..<(ips.count/4) {
                    var ctrlPoint1 = CGPoint()
                    let cp = cgContext.currentPointOfPath
                    let (cpx, cpy)  = (c.command == "s") ? (cp.x, cp.y) : (0.0, 0.0)

                    if j == 0 {
                        switch previousInstruction.command {
                        case "C", "c":
                            let previousCommandcount = (previousParameters.count / 6) - 1
                            ctrlPoint1.x = cp.x  + previousParameters[6*previousCommandcount+4] - previousParameters[6*previousCommandcount+2]
                            ctrlPoint1.y = cp.y + previousParameters[6*previousCommandcount+5] - previousParameters[6*previousCommandcount+3]
                        case "S", "s":
                            let previousCommandcount = (previousParameters.count / 4) - 1
                            ctrlPoint1.x = cp.x + previousParameters[4*previousCommandcount+2] - previousParameters[4*previousCommandcount+0]
                            ctrlPoint1.y = cp.y + previousParameters[4*previousCommandcount+3] - previousParameters[4*previousCommandcount+1]
                        default:
                            return
                        }
                      
                    } else {
                        switch c.command {
                        case "S", "s":
                            ctrlPoint1.x =  cp.x + ips[4*(j-1)+2] - ips[4*(j-1)+0]
                            ctrlPoint1.y = cp.y + ips[4*(j-1)+3] - ips[4*(j-1)+1]
                        default:
                            return
                        }
                    }
                    
                    let ctrlPoint2 = CGPoint(x:ips[4*j]+cpx, y:ips[4*j+1]+cpy)
                    let endPoint = CGPoint(x:ips[4*j+2]+cpx, y:ips[4*j+3]+cpy)
                    cgContext.addCurve(to: endPoint, control1: ctrlPoint1, control2: ctrlPoint2)
                }
            
                break;
            case "Q", "q":
                if ips.count % 4 != 0 { break }
                for j in 0..<(ips.count/4) {
                    let cp = cgContext.currentPointOfPath
                    let (cpx, cpy)  = (c.command == "q") ? (cp.x, cp.y) : (0.0, 0.0)
                    let ctrlPoint = CGPoint(x:ips[4*j]+cpx, y:ips[4*j+1]+cpy)
                    let endPoint = CGPoint(x:ips[4*j+2]+cpx, y:ips[4*j+3]+cpy)
                    cgContext.addQuadCurve(to: endPoint, control: ctrlPoint)
                }
            case "Z","z":
                cgContext.closePath()
            default:
                break;
            }

        }
        
        cgContext.drawPath(using: .stroke)
        
        //let instructions = pathString.split(separator: ["m", "M", "l", "L", "Z", "z", "H", "h", "V", "v"])
        
    }
}
