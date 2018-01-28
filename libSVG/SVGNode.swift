//
//  Tree.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/18/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation

typealias preTraverseNodeFunction = (SVGNode, SVGNodeOperation , [String:Any]?, SVGTraverseContext) -> Void
typealias postTraverseNodeFunction = (SVGNode, SVGNodeOperation , [String:Any]?, SVGTraverseContext) -> Void

enum SVGNodeOperation:CustomStringConvertible {
    case render, export, print, balance, none, any
    
    public var description:String {
        switch self {
            case .render: return "render"       //render with the parameters
            case .export: return "export"       //Create a file
            case .print: return "print"         //Dump
            case .balance: return "balance"     //Maintain the tree after addition/removal
            case .none: return "none"           //Do Nothing
            case .any: return "any"             //Do Anything
        }
    }
    
//    public var preNodeOperationFunction:preTraverseNodeFunction? {
//        switch self {
//            case .render: return SVGNode.preTraverseRender?
//            case .export: return SVGNode.preTraverseExport?
//            case .print: return SVGNode.preTraversePrint?
//            case .balance: return SVGNode.preTraverseBalance?
//            case .none: return nil
//            case .any: return nil
//        }
//    }
    
}

struct SVGTraverseContext
{
    var level:Int = 0
    var childIndex:Int = 0
    var traverseResult:Any?=nil
    var traverseError:Any?=nil
    var refCon:Any? = nil
    
    
    init() {
    }
    
    init(context:SVGTraverseContext) {
        self.level = context.level
        self.childIndex = context.childIndex
        self.traverseResult = context.traverseResult
        self.traverseError = context.traverseError
        self.refCon = context.refCon
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
    init(value:SVGElement?=nil, parentNode:SVGNode? = nil) {
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
    func applyOperation(operation:SVGNodeOperation, parameters:[String:Any]? = nil) -> Any? {
        let context = SVGTraverseContext()
        switch operation {
        case .render:
            let _ = traverse(operation:.render, parameters:parameters, context:context, preTraverseFunction:preTraverseRender, postTraverseFunction:postTraverseRender)
        case .export:
            let _ = traverse(operation:.export, parameters:parameters, context:context, preTraverseFunction:preTraverseExport, postTraverseFunction:postTraverseExport)
        case .print:
            let _ = traverse(operation:.print, parameters:parameters,context:context, preTraverseFunction:preTraversePrint, postTraverseFunction:postTraversePrint)
        case .balance:
            let _ = traverse(operation:.balance, context:context, preTraverseFunction:preTraverseBalance, postTraverseFunction:postTraverseBalance)
        case .none:
            return nil
        case .any:
            return nil
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
        return self.applyOperation(operation: .print, parameters: nil) as! String
    }
    
    //Adding a child will modify the children
    func appendChild(childNode:SVGNode) -> Void {
        
        //Balance all in level equal or inferior to child. Because we start from child, we need to properly initialize the context
        var context = SVGTraverseContext()
        context.level = self.treeIdentifier.count - 1
        context.childIndex = self.children.count

        self.children.append(childNode)
        childNode.parent = self

        let _ = childNode.traverse(operation: .balance, parameters: nil, context: context, preTraverseFunction:preTraverseBalance, postTraverseFunction:postTraverseBalance)
    }
    
    //Adding a child will modify the children
    func insertChild(childNode:SVGNode, at:Int) -> Void {
        
        var context = SVGTraverseContext()
        context.level = self.treeIdentifier.count - 1
        context.childIndex = 0
            
        self.children.insert(childNode, at:at)
        childNode.parent = self
        let _ = self.traverse(operation: .balance, parameters: nil, context: context, preTraverseFunction:preTraverseBalance, postTraverseFunction:postTraverseBalance)        
    }
    
    //Remove a child based on its index
    func removeChild(childIndex:Int) -> Bool {
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
    
    //Remove a child based on its identifier. It may or not be a direct child
    func removeChild(childTreeIdentifier:String) -> Bool {
        var result:Bool = false
        
        for (index, child) in children.enumerated() {
            if child.treeIdentifier == childTreeIdentifier {
                result = removeChild(childIndex: index)
                break
            }
        }
        return result
    }

    
    //Will compute height of a tree
    func height() -> Int {
        if let maxVal = children.map({ (node:SVGNode) -> Int in return node.height() }).max() {
            return 1 + maxVal
        } else {
            return 1
        }
    }
    
    
    
    //Tree iterator
    func traverse(operation:SVGNodeOperation = .none, parameters:[String:Any]? = nil, context:SVGTraverseContext, preTraverseFunction:preTraverseNodeFunction? = nil, postTraverseFunction:postTraverseNodeFunction? = nil ) -> (Bool, Any?) {
        
        if let preTraverseFunction = preTraverseFunction {
            preTraverseFunction(self, operation, parameters, context)
        }
        
        for (index, child) in children.enumerated() {
            var childContext = SVGTraverseContext(context:context)
            childContext.level = childContext.level + 1
            childContext.childIndex = index
            let _  = child.traverse( operation:operation, parameters: parameters, context: childContext, preTraverseFunction:preTraverseFunction, postTraverseFunction:postTraverseFunction)
        }
        
        if let postTraverseFunction = postTraverseFunction {
            postTraverseFunction(self, operation, parameters, context)
        }
        
        return (true, nil)
    }
    
        //Transactions
    
    
        //Predefined function
    fileprivate func preTraversePrint(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) -> Void{
        var nodeString = String(repeating: " ", count: context.level)
        nodeString  = nodeString + "+ " + "<\(type(of: node)):\((node.value! as SVGElement).tag.name)>"
        nodeString  = nodeString + " Level: " + String(context.level) + ", Index: " + String(context.childIndex) + "\n"
        print(nodeString)
    }
    
    fileprivate func postTraversePrint(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) {
    
    }
    
    fileprivate func preTraverseExport(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?, context:SVGTraverseContext) {
        
    }
    
    fileprivate func postTraverseExport(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?, context:SVGTraverseContext) {
        
    }
    
    fileprivate func preTraverseBalance(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) {
        print("== preTraverseBalance")
        if let parent = node.parent {
            print("  Parent " + parent.treeIdentifier)
            print("  Index " + String(context.childIndex))
            node.treeIdentifier = parent.treeIdentifier + String(context.childIndex)
            print("  Now " + node.treeIdentifier)
        }
    }
    
    fileprivate func postTraverseBalance(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) {
        
    }
    
    fileprivate func preTraverseRender(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) {
        
    }
    
    fileprivate func postTraverseRender(node:SVGNode, operation:SVGNodeOperation, parameters:[String:Any]?,  context:SVGTraverseContext) {
        
    }
}
