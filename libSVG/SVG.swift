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


/* Options to instiantiate the SVG */
struct SVGOptions:OptionSet {
    let rawValue: Int
    
    static let none = SVGOptions(rawValue: 0)
    static let noParseAtLoad = SVGOptions(rawValue: 1 << 0)
    static let verboseActions = SVGOptions(rawValue: 1 << 2)
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
    var renderers:[String:SVGRenderer] = [String:SVGRenderer]()
    
    //simply create an empty SVG, with no size. If one want to have a default sze the SVG should be passed an SVGDefault (400/600)

    init(options:SVGOptions?=nil) {
        self.sourcefilePath = nil
        self.sourcefileURL = nil
        self.svgTree = nil
        self.isValidSVG = true
        self.verbose =  options != nil && options!.contains(.verboseActions)
    }
    
    //We should make it optional to parse
    init(content:String, options:SVGOptions?=nil) {
        self.sourcefilePath = nil
        self.sourcefileURL = nil
        self.svgTree = nil
        self.verbose =  options != nil && options!.contains(.verboseActions)
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
        self.verbose =  options != nil && options!.contains(.verboseActions)
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
    
    func addRendererer(renderer:SVGRenderer) {
        renderers[renderer.uuid] = renderer
    }
    
    func renderToDestination(destinationUUID:String, rendererUUID:String? = nil) {
        guard self.isValidSVG == true else { return }
        guard let destination = renderDestinations[destinationUUID] else {
            if self.verbose {
                print("[renderToDestination] invalid destination")
            }
            return
        }
        
            //if no renderer create a CoreGraphics one
        var realRendererUUID:String
        if nil == rendererUUID {
            let cgRenderer = SVGCoreGraphicsRenderer() 
            addRendererer(renderer: cgRenderer)
            realRendererUUID = cgRenderer.uuid
        } else {
            realRendererUUID = rendererUUID!
            if nil == renderers[realRendererUUID] {
                let cgRenderer = SVGCoreGraphicsRenderer()
                addRendererer(renderer: cgRenderer)
                realRendererUUID = cgRenderer.uuid
            }
        }
        
        let _ = self.svgTree?.applyOperation(operation: .render, parameters: ["destination" : destination, "renderer": renderers[realRendererUUID]!])
        
    }
    
    func dump() -> Void {
        guard self.isValidSVG == true else { return }
        let _ = self.svgTree?.applyOperation(operation: .print, parameters: nil)
    }
    
    //For verbose mode: display the parsed XML with XML syntax
    internal func preHookParseXMLNode(node:SVGNode, depth:Int) -> Void {
        
        guard self.verbose == true else { return }
        
        let spaces = String(repeating: " ", count: depth)
        let nodeName = node.value!.tag.name
        let attributeString = node.value!.attributes?.flatMap({ (key:String, value:String) -> String in
            return key + "=\"" + value + "\""
        }).joined(separator: " ")
        
        if let attributeString = attributeString {
            if attributeString.count != 0 {
                print(spaces + "<" + nodeName + " " + attributeString + ">")
            } else {
                print(spaces + "<" + nodeName + ">")
            }
            
            if let content = node.value!.content {
                if content.count != 0 {
                    print(spaces + "  " + content)
                }
            }
        }
    }

    //For verbose mode: display the parsed XML with XML syntax
    internal func postHookParseXMLNode(node:SVGNode, depth:Int) -> Void {
        guard self.verbose == true else { return }
        
        let spaces = String(repeating: " ", count: depth)
        let nodeName = node.value!.tag.name

        print(spaces + "<" + nodeName + "/>")
    }

    /* This is for the parsing of one node only (not an array of nodes, although there is a pointer).
       It is up to the function to call itself with either child or sibling */
    internal func parseXMLNode(nodePtr:xmlNodePtr?, parentNode:SVGNode?, depth:Int=0) -> Void {
        
        var doConsiderXMLNode = false
            //validate iput data
        guard let realNodePtr = nodePtr else { return }
        var node:xmlNode = realNodePtr.pointee
        let nodeName = String(cString:node.name)
        
            //create the needed lib entities
        guard let tmpTag = SVGTag(name: nodeName) else {
            return
        }
        
        let tmpElement = SVGElement(tag:tmpTag)
        let tmpNode = SVGNode(value: tmpElement)
        
        var nodeProperties = [String:String]()
        if node.type == XML_ELEMENT_NODE {
            doConsiderXMLNode = true
            if let properties:xmlAttrPtr = node.properties {
                var cur_attr = properties.pointee
                repeat {
                    let attr_name:String = String(cString:cur_attr.name)
                    let attr_value = String(cString:xmlGetProp(&node, attr_name))
                    nodeProperties[attr_name] = attr_value
                    
                    tmpElement.addAttribute(key: attr_name, value: attr_value)
                    if nil == cur_attr.next {
                        break;
                    } else {
                        cur_attr = cur_attr.next.pointee
                    }
                } while true
            }

        } else if node.type == XML_TEXT_NODE {
            if let content = node.content {
                let contentStr = String(cString:content).trimmingCharacters(in: .whitespacesAndNewlines)
                if contentStr.count != 0 {
                    doConsiderXMLNode = true
                    tmpElement.content = contentStr
                }
            }
        }
        
        //
        //Add the parent, if not set it
        if doConsiderXMLNode  {
            preHookParseXMLNode(node:tmpNode, depth:depth)

            if nil == parentNode {
                self.svgTree = tmpNode //TODO : think it has really sense to have it there
            } else {
                _ = parentNode!.appendChild(childNode: tmpNode)
            }
            parseXMLNode(nodePtr:node.children, parentNode:tmpNode, depth:depth+1)
            postHookParseXMLNode(node:tmpNode, depth:depth)
        }
        parseXMLNode(nodePtr:node.next, parentNode:parentNode, depth:depth)
        
    }
}
