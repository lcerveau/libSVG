//
//  Tag.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/19/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation

enum TagCategory:Int, CustomStringConvertible {
    case container = 1
    case animation
    case descriptive
    case shape
    case filterPrimitive
    case structural
    case textContent
    case gradient
    
    public var description: String {
        switch self {
            case .container:
                return "container"
            case .animation:
                return "animation"
            case .descriptive:
                return "descriptive"
            case .shape:
                return "shape"
            case .structural:
                return "structural"
            case .gradient:
                return "gradient"
            case .textContent:
                return "text content"
            default:
                return "none"
        }
    }
}

class SVGTag {
    
    var name:String
    
    init?(name:String) {
        guard SVGTag.allTags[name] != nil else { return nil }
        self.name = name
    }
    
    var category:String
    {
        get {
            if let t = SVGTag.allTags[name], let c = t["category"] as? TagCategory {
                return c.description
            } else {
                return "unknown tag"
            }
        }
    }
    
    // all tags
    static let allTags:[String:[String:Any]] = [
        "a":["category": TagCategory.container],
        "altGlyph":["category": TagCategory.textContent],
        "altGlyphDef":["category": TagCategory.textContent],
        "altGlyphItem":["category": TagCategory.textContent],
        "animate":["category":TagCategory.animation],
        "animateColor":["category": TagCategory.animation],
        "animateMotion":["category":TagCategory.animation],
        "animateTransform":["category":TagCategory.animation],
        "circle":["category":TagCategory.shape],
//        "clipPath":[":TagCategory."::TagCategory.shape],
//        "color-profile":[":TagCategory."::TagCategory.shape],
//        "cursor":[":TagCategory."::TagCategory.shape],
        "defs":["category":TagCategory.container],
        "desc":["category":TagCategory.descriptive],
        "ellipse":["category":TagCategory.shape],
        "feBlend":["category":TagCategory.filterPrimitive],
        "feColorMatrix":["category":TagCategory.filterPrimitive],
        "feComponentTransfer":["category":TagCategory.filterPrimitive],
        "feComposite":["category":TagCategory.filterPrimitive],
        "feConvolveMatrix":["category":TagCategory.filterPrimitive],
        "feDiffuseLighting":["category":TagCategory.filterPrimitive],
        "feDisplacementMap":["category":TagCategory.filterPrimitive],
        "feDistantLight":["category":TagCategory.filterPrimitive],
        "feFlood":["category":TagCategory.filterPrimitive],
        "feFuncA":["category":TagCategory.filterPrimitive],
        "feFuncB":["category":TagCategory.filterPrimitive],
        "feFuncG":["category":TagCategory.filterPrimitive],
        "feFuncR":["category":TagCategory.filterPrimitive],
        "feGaussianBlur":["category":TagCategory.filterPrimitive],
        "feImage":["category":TagCategory.filterPrimitive],
        "feMerge":["category":TagCategory.filterPrimitive],
        "feMergeNode":["category":TagCategory.filterPrimitive],
        "feMorphology":["category":TagCategory.filterPrimitive],
        "feOffset":["category":TagCategory.filterPrimitive],
        "fePointLight":["category":TagCategory.filterPrimitive],
        "feSpecularLighting":["category":TagCategory.filterPrimitive],
        "feSpotLight":["category":TagCategory.filterPrimitive],
        "feTile":["category":TagCategory.filterPrimitive],
        "feTurbulence":["category":TagCategory.filterPrimitive],
        "filter":["category":TagCategory.filterPrimitive],
//        "font":[],
//        "font-face":[],
//        "font-face-format":[],
//        "font-face-name":[],
//        "font-face-src":[],
//        "font-face-uri":[],
//        "foreignObject":[],
        "g":["category":TagCategory.container],
        "glyph":["category":TagCategory.container],
//        "glyphRef":[],
//        "hkern":[],
//        "image":[],
        "line":["category":TagCategory.shape],
        "linearGradient":["category":TagCategory.gradient],
        "marker":["category":TagCategory.container],
        "mask":["category":TagCategory.container],
        "metadata":["category":TagCategory.descriptive],
        "missing-glyph":["category":TagCategory.container],
//        "mpath":[],
        "path":["category":TagCategory.shape],
        "pattern":["category":TagCategory.container],
        "polygon":["category":TagCategory.shape],
        "polyline":["category":TagCategory.shape],
        "radialGradient":["category":TagCategory.gradient],
        "rect":["category":TagCategory.shape],
//        "script":[],
        "set":["category":TagCategory.animation],
//        "stop":[],
        "style":["category":TagCategory.textContent],
        "svg":["category":TagCategory.container],
        "switch":["category":TagCategory.container],
        "symbol":["category":TagCategory.container],
        "text":["category":TagCategory.textContent],
        "textPath":["category":TagCategory.textContent],
        "title":["category":TagCategory.descriptive],
//        "tref":[],
//        "tspan":[],
//        "use":[],
//        "view":[],
//        "vkern":[]
    ]
    
    class func createElement(name:String, attributes:[String:String]? = nil) -> SVGElement? {
        guard let tmpTag = SVGTag(name: name) else { print("Unknown tag:" + name); return nil }
    
        switch tmpTag.name {
        case "svg":
            return SVGTagSVG(tag:tmpTag)
        default:
            print("CLASS NEED TO BE CREATED:" + tmpTag.name);
            return SVGElement(tag:tmpTag)
        }
    }
}


protocol SVGTagInstance {
    func render(mode:String, parameters: inout [String:Any]?, attributes:[String:String]?);
    func print(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?);
    func export(mode:String, parameters:inout [String:Any]?, attributes:[String:String]?);
}
