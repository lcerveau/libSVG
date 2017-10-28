//
//  Tree.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/18/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation


typealias preTraverseNodeFunction = (SVGNode, Int, Int) -> Void
typealias postTraverseNodeFunction = (SVGNode, Int, Int) -> Void

enum SVGNodeOperation:CustomStringConvertible {
    case render, export, print
    
    public var description:String {
        switch self {
            case .render:
                return "render"
            case .export:
                return "export"
            case .print:
                return "print"
        }
    }
}

enum SVGNodeOperationParameter:String {
    case renderContextType, renderImageDestinationAttributes    
}

class SVGNode : CustomStringConvertible,CustomDebugStringConvertible {
    
    var value:SVGElement?
    var treeIdentifier:String
    var children:[SVGNode] = [SVGNode]()
    var parent:SVGNode?
    
        //Life cycle: creation
    init(value:SVGElement?, parentNode:SVGNode? = nil) {
        self.value = value
        
        if let parentNode = parentNode {
            self.parent = parentNode
            self.treeIdentifier = parentNode.treeIdentifier + String(parentNode.children.count)
            self.parent?.children.append(self)
        } else {
            self.treeIdentifier = "0"
        }
    }
    
        //Operation: this is the main entry point
    func applyOperation(operation:SVGNodeOperation, parameters:[String:Any]?) -> Any? {
        switch operation {
        case .render:
            print("render")
        case .export:
            print("export")
        case .print:
            print("print")
        }
        return nil
    }
    
        //Print a simple node
    public var description: String {
        if let tmpValue = self.value {
            return "<\(type(of: self)):\(tmpValue)>"
        } else {
            return "<\(type(of: self))>"
        }
    }
    
    public var debugDescription: String {
        var nodeString:String = ""
        traverse(
            
            preTraverseFunction: { (node:SVGNode, level:Int, childIndex:Int) in
                if level != 0 {
                    for _ in 0...level - 1 {
                        nodeString = nodeString + "  "
                    }
                }
                nodeString  = nodeString + "+ " + "<\(type(of: node)):\((node.value! as SVGElement).tag)>"
                nodeString  = nodeString + " Level: " + String(level) + ", Index: " + String(childIndex) + "\n"
        },
            
            postTraverseFunction: { (node:SVGNode, level:Int, childIndex:Int) in
                
                
        })
        return nodeString
    }
    
    //Adding a child will modify the children
    func appendChild(childNode:SVGNode) -> Bool {
        self.children.append(childNode)
        childNode.parent = self
        childNode.treeIdentifier = self.treeIdentifier + String(self.children.count)
        return true
    }
    
    //Adding a child will modify the children
    func insertChild(childNode:SVGNode, at:Int) -> Bool {
        self.children.insert(childNode, at:at)
        childNode.parent = self
        
        for (index, child) in children.enumerated() {
            if index >= at {
                child.treeIdentifier = self.treeIdentifier + String(index)
            }
        }
        return true
    }
    
    //Remove a child based on its index
    func removeChild(childIndex:Int, recursive:Bool) -> Bool {
        guard childIndex >= 0  else { return false }
        guard childIndex < self.children.count else { return false }
        children.remove(at: childIndex)
        
        for (index, child) in children.enumerated() {
            if index >= childIndex {
                child.treeIdentifier = self.treeIdentifier + String(index)
            }
        }
        return true
    }
    
    //Will compute height of a tree
    func height() -> Int {
        if let maxVal = children.map({ (node:SVGNode) -> Int in return node.height() }).max() {
            return 1 + maxVal
        } else {
            return 0
        }
    }
    
    fileprivate func removeChildWithOption(childIndex:Int, recursive:Bool) -> Bool {
        guard childIndex >= 0  else { return false }
        guard childIndex < self.children.count else { return false }
        children.remove(at: childIndex)
        
        for (index, child) in children.enumerated() {
            if index >= childIndex {
                child.treeIdentifier = self.treeIdentifier + String(index)
            }
        }
        return true
    }
    
    
    
    //Remove a child based on its identifier
    func removeChild(childTreeIdentifier:String, recursive:Bool) -> Bool {
        var result:Bool = false
        
        for (index, child) in children.enumerated() {
            if child.treeIdentifier == childTreeIdentifier {
                result = removeChild(childIndex: index, recursive: recursive)
                break
            }
        }
        return result
    }
    
    //Tree iterator
    func traverse(level:Int = 0, childIndex:Int = 0, preTraverseFunction:preTraverseNodeFunction? = nil, postTraverseFunction:postTraverseNodeFunction? = nil ) {
        
        if let preTraverseFunction = preTraverseFunction {
            preTraverseFunction(self, level, childIndex)
        }
        
        for (index, child) in children.enumerated() {
            child.traverse(level: level+1, childIndex: index, preTraverseFunction:preTraverseFunction, postTraverseFunction:postTraverseFunction)
        }
        
        if let postTraverseFunction = postTraverseFunction {
            postTraverseFunction(self, level, childIndex)
        }
    }
    
    //will parse the tree and set up identifier
    private func updateIdentifiers() {
        traverse ()
    }
    
}
