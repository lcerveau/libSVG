//
//  Tag.swift
//  libSVG
//
//  Created by Laurent Cerveau on 02/19/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation

enum Category:Int, CustomStringConvertible {
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
    
    // all tags
    //query by parameters and exentiosn
    static let allTags:[String:[String:Any]] = [
        "a":["category": Category.container],
        "altGlyph":["category": Category.textContent],
        "altGlyphDef":["category":Category.textContent],
        "altGlyphItem":["category":Category.textContent],
        "animate":["category":Category.animation],
        "animateColor":["category":Category.animation],
        "animateMotion":["category":Category.animation],
        "animateTransform":["category":Category.animation],
        "circle":["category":Category.shape],
//        "clipPath":["category":Category.shape],
//        "color-profile":["category":Category.shape],
//        "cursor":["category":Category.shape],
        "defs":["category":Category.container],
        "desc":["category":Category.descriptive],
        "ellipse":["category":Category.shape],
        "feBlend":["category":Category.filterPrimitive],
        "feColorMatrix":["category":Category.filterPrimitive],
        "feComponentTransfer":["category":Category.filterPrimitive],
        "feComposite":["category":Category.filterPrimitive],
        "feConvolveMatrix":["category":Category.filterPrimitive],
        "feDiffuseLighting":["category":Category.filterPrimitive],
        "feDisplacementMap":["category":Category.filterPrimitive],
        "feDistantLight":["category":Category.filterPrimitive],
        "feFlood":["category":Category.filterPrimitive],
        "feFuncA":["category":Category.filterPrimitive],
        "feFuncB":["category":Category.filterPrimitive],
        "feFuncG":["category":Category.filterPrimitive],
        "feFuncR":["category":Category.filterPrimitive],
        "feGaussianBlur":["category":Category.filterPrimitive],
        "feImage":["category":Category.filterPrimitive],
        "feMerge":["category":Category.filterPrimitive],
        "feMergeNode":["category":Category.filterPrimitive],
        "feMorphology":["category":Category.filterPrimitive],
        "feOffset":["category":Category.filterPrimitive],
        "fePointLight":["category":Category.filterPrimitive],
        "feSpecularLighting":["category":Category.filterPrimitive],
        "feSpotLight":["category":Category.filterPrimitive],
        "feTile":["category":Category.filterPrimitive],
        "feTurbulence":["category":Category.filterPrimitive],
        "filter":["category":Category.filterPrimitive],
//        "font":[],
//        "font-face":[],
//        "font-face-format":[],
//        "font-face-name":[],
//        "font-face-src":[],
//        "font-face-uri":[],
//        "foreignObject":[],
        "g":["category":Category.container],
        "glyph":["category":Category.container],
//        "glyphRef":[],
//        "hkern":[],
//        "image":[],
        "line":["category":Category.shape],
        "linearGradient":["category":Category.gradient],
        "marker":["category":Category.container],
        "mask":["category":Category.container],
        "metadata":["category":Category.descriptive],
        "missing-glyph":["category":Category.container],
//        "mpath":[],
        "path":["category":Category.shape],
        "pattern":["category":Category.container],
        "polygon":["category":Category.shape],
        "polyline":["category":Category.shape],
        "radialGradient":["category":Category.gradient],
        "rect":["category":Category.shape],
//        "script":[],
        "set":["category":Category.animation],
//        "stop":[],
//        "style":[],
        "svg":["category":Category.container],
        "switch":["category":Category.container],
        "symbol":["category":Category.container],
//        "text":[],
//        "textPath":[],
        "title":["category":Category.descriptive],
//        "tref":[],
//        "tspan":[],
//        "use":[],
//        "view":[],
//        "vkern":[]
    ]
    
}
