//
//  Interface.swift
//  libSVG
//
//  Created by Laurent Cerveau on 11/3/16.
//  Copyright © 2016 MMyneta. All rights reserved.
//

import Foundation
import clibxml
import CoreServices
import ImageIO


//enum SVGLibInitOptions:Op {
//    case .parseAtLoad
//}

class SVG {
    
        //we keep both for manipulation
    var fileURL:URL?
    var filePath:String?
    var isValidSVG:Bool = false
    var isParsed:Bool = false
    
    var svgTree:SVGNode?
    
        //simply create an empty SVG, with default size (400/600)
    init() {
        self.filePath = nil
        self.fileURL = nil
        self.svgTree = nil
        self.isValidSVG = true
    }
    
        //We should make it optional
    init(path:String) {
        
        self.filePath = path
        guard FileManager.default.fileExists(atPath: path) else { return }
        self.fileURL = URL(fileURLWithPath: path)
        
        self.parse()
        self.isValidSVG = true
    }
    
        //We should make it optional
    init(url:URL) {
        self.fileURL = url
        self.filePath = self.fileURL?.path
        guard FileManager.default.fileExists(atPath: self.filePath!) else { return }
        
        self.parse()
        self.isValidSVG = true
    }
    
        
    func parse() {
        guard let filePath = self.filePath else { return }
        guard let filePathCArray = filePath.cString(using: String.Encoding.utf8) else { return }
            
        filePathCArray.withUnsafeBufferPointer { ptr in
            guard let xmlCharPath:UnsafePointer<CChar> = ptr.baseAddress else { return }
            guard let xmlFileDoc:xmlDocPtr = xmlReadFile(xmlCharPath, nil, 0) else { return }
            guard let rootNode:xmlNodePtr =  xmlDocGetRootElement(xmlFileDoc) else { return }
            
            print("\n\n")
            parseXMLNode(nodePtr:rootNode, parentNode:nil, depth:0)
            print("\n\n")
            xmlFreeDoc(xmlFileDoc)
            xmlCleanupParser()
            
            if let dd = self.svgTree?.debugDescription {
              print(dd)
            }
        }
        
        isParsed = true
    }
    
    func drawToContext(context:CGContext) {
        
    }
    
    internal func parseXMLNode(nodePtr:xmlNodePtr, parentNode:SVGNode?, depth:Int) -> Void {
        
        let node:xmlNode = nodePtr.pointee
        var cur_node:xmlNode = node
        repeat{
            var beginStr = ""
            var endStr = ""
            var contentStr = ""
            
            let nodeName = String(cString:cur_node.name)
            for _ in 0..<depth {
                beginStr += "  "
                endStr += "  "
            }
            beginStr += "<"+nodeName
            endStr += "</"+nodeName
            
            let tmpElement = SVGElement(tag:nodeName)
            let tmpNode = SVGNode(value: tmpElement)
            if nil == parentNode {
                self.svgTree = tmpNode
            } else {
                _ = parentNode!.appendChild(childNode: tmpNode)
            }
            
            //print(cur_node.type.rawValue)
            var nodeProperties = [String:String]()
            var printName = false
            if cur_node.type.rawValue == 1 {
                printName = true
                if let properties:xmlAttrPtr = cur_node.properties {
                    var cur_attr = properties.pointee
                    repeat {
                        let attr_name:String = String(cString:cur_attr.name)
                        let attr_value = String(cString:xmlGetProp(&cur_node, attr_name))
                        nodeProperties[attr_name] = attr_value
                        
                        if nil == cur_attr.next {
                            break;
                        } else {
                            cur_attr = cur_attr.next.pointee
                        }
                    } while true
                }
            } else if cur_node.type.rawValue == 3 {
                if let content = cur_node.content {
                    contentStr = String(cString:content).trimmingCharacters(in: .whitespacesAndNewlines)
                    printName = (contentStr.characters.count != 0)
                }
                
            }
            
            if printName {
                for(attr_name, attr_value) in nodeProperties {
                    beginStr += " \(attr_name)=\"\(attr_value)\""
                }
                
                beginStr += ">"
                endStr += ">"
                if cur_node.type.rawValue == 1 {
                    print(beginStr)
                } else if cur_node.type.rawValue == 3 {
                    print(contentStr)
                }
            }
            
            if cur_node.children != nil {
                parseXMLNode(nodePtr:cur_node.children, parentNode:tmpNode, depth:depth+1)
                if printName && cur_node.type.rawValue == 1 {
                    print(endStr)
                }
            } else {
                beginStr+=endStr
                if printName && cur_node.type.rawValue == 1 {
                    print(beginStr)
                }
            }
            
            if nil == cur_node.next {
                break
            } else {
                cur_node = cur_node.next.pointee
            }
        } while true
    }
    
}
