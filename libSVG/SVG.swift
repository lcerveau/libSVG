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


enum SVGOptions:Int, OptionSet {
    case none = 0, noParseAtLoad = 1, verboseActions = 2
    
    init(rawValue:Int) {
        self.init(rawValue:rawValue)
    }
}

class SVG {
    
        //we keep both for manipulation
    var sourcefileURL:URL?
    var sourcefilePath:String?
    var isValidSVG:Bool = false
    var isParsed:Bool = false
    var verbose:Bool = false
    
    var svgTree:SVGNode?
    var renderDestinations:[String:SVGRenderDestination] = [String:SVGRenderDestination]()
    
    //simply create an empty SVG, with no size. If one want to have a default sze the SVG should be passed an SVGDefault (400/600)
    init(options:SVGOptions?=nil) {
        self.sourcefilePath = nil
        self.sourcefileURL = nil
        self.svgTree = nil
        self.isValidSVG = true
    }
    
    //We should make it optional to parse
    init(content:String, options:SVGOptions?=nil) {
        self.sourcefilePath = nil
        self.sourcefileURL = nil
        self.svgTree = nil
    }
    
        //We should make it optional to parse
    init(path:String, options:SVGOptions?=nil) {
        
        self.sourcefilePath = path
        guard FileManager.default.fileExists(atPath: path) else { return }
        self.sourcefileURL = URL(fileURLWithPath: path)
        if nil == options || false ==  options!.contains(.noParseAtLoad) {
            self.parseSource()
            self.isValidSVG = true
        }

    }
    
        //We should make it optional to parse
    init(url:URL, options:SVGOptions?=nil) {
        self.sourcefileURL = url
        self.sourcefilePath = self.sourcefileURL?.path
        guard FileManager.default.fileExists(atPath: self.sourcefilePath!) else { return }
        if nil == options || false ==  options!.contains(.noParseAtLoad) {
            self.parseSource()
            self.isValidSVG = true
        }
    }
    
        //Parse when this a file. Calling this on
    func parseSource() {
        guard let filePath = self.sourcefilePath else { return }
        guard let filePathCArray = filePath.cString(using: String.Encoding.utf8) else { return }
            
        filePathCArray.withUnsafeBufferPointer { ptr in
                //Check parameters and file validity
            guard let xmlCharPath:UnsafePointer<CChar> = ptr.baseAddress else { return }
            guard let xmlFileDoc:xmlDocPtr = xmlReadFile(xmlCharPath, nil, 0) else { return }
            guard let rootNode:xmlNodePtr =  xmlDocGetRootElement(xmlFileDoc) else { return }
            
                //Do the parsing
            parseXMLNode(nodePtr:rootNode, parentNode:nil)
            
                //Do the parsing
            xmlFreeDoc(xmlFileDoc)
            xmlCleanupParser()            
        }
        
        isParsed = true
    }
    
        //
    func addRenderDestination(destination:SVGRenderDestination) {
        renderDestinations[destination.uuid] = destination
    }
    
    func renderToDestination(destinationUUID:String) {
        let _ = self.svgTree?.applyOperation(operation: .render, parameters: ["destination" : renderDestinations[destinationUUID]])
    }
    
    func dump() -> Void {
    }
    
    internal func parseXMLNode(nodePtr:xmlNodePtr, parentNode:SVGNode?, depth:Int=0) -> Void {
        
        let node:xmlNode = nodePtr.pointee
        var cur_node:xmlNode = node
        repeat{
            var beginStr = ""
            var endStr = ""
            var contentStr = ""
            
            let nodeName = String(cString:cur_node.name)
            //print(nodeName)
            for _ in 0..<depth {
                beginStr += "  "
                endStr += "  "
            }
            beginStr += "<"+nodeName
            endStr += "</"+nodeName
            
                //The Tag is the SVG entity, the Element is the instance of it, the Node encapsulates it into a tree structure
            if let tmpTag = SVGTag(name: nodeName) {
                let tmpElement = SVGElement(tag:tmpTag)
                let tmpNode = SVGNode(value: tmpElement)
                
                //print(tmpNode)
                if nil == parentNode {
                    self.svgTree = tmpNode
                } else {
                    _ = parentNode!.appendChild(childNode: tmpNode)
                }
                var nodeProperties = [String:String]()
                var printName = false
              //  print(cur_node.type)
                if cur_node.type == XML_ELEMENT_NODE {
                    printName = true
                        //loop over all properties
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
                    //tmpNode.value?.type
                } else if cur_node.type == XML_TEXT_NODE {
                    if let content = cur_node.content {
                        contentStr = String(cString:content).trimmingCharacters(in: .whitespacesAndNewlines)
//                        printName = (contentStr.characters.count != 0)
                        tmpElement.content = contentStr
                    }
                    
                }
                
//                if printName {
//                    for(attr_name, attr_value) in nodeProperties {
//                        beginStr += " \(attr_name)=\"\(attr_value)\""
//                    }
//
//                    beginStr += ">"
//                    endStr += ">"
//                    if cur_node.type.rawValue == 1 {
//                        print(beginStr)
//                    } else if cur_node.type.rawValue == 3 {
//                        print(contentStr)
//                    }
//                }
//
                if cur_node.children != nil {
                    parseXMLNode(nodePtr:cur_node.children, parentNode:tmpNode, depth:depth+1)
                }
//                    if printName && cur_node.type.rawValue == 1 {
//                        print(endStr)
//                    }
//                } else {
//                    beginStr+=endStr
//                    if printName && cur_node.type.rawValue == 1 {
//                        print(beginStr)
//                    }
//                }
                
                if nil == cur_node.next {
                    break
                } else {
                    cur_node = cur_node.next.pointee
                }
            } else {
                if cur_node.children != nil {
                    parseXMLNode(nodePtr:cur_node.children, parentNode:nil, depth:depth+1)
                }
                
                if nil == cur_node.next {
                    break
                } else {
                    cur_node = cur_node.next.pointee
                }
                print("Unknown tag"+nodeName)
            }
        } while true
    }
    
}
