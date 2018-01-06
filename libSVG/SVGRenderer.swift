//
//  SVGRenderer.swift
//  libSVG
//
//  Created by Laurent Cerveau on 04/14/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation
import CoreGraphics

//renderer will be OpenGL or Native or HTML
protocol SVGRenderer {
    var identifier:String { get }
    var uuid:String { get }
}

class SVGCoreGraphicsRenderer:SVGRenderer {
    var identifier: String = "com.libsvg.renderer.coregraphics"
    var uuid = UUID().uuidString
}

class SVGOpenGLRenderer:SVGRenderer {
    var identifier: String = "com.libsvg.renderer.opengl"
    var uuid = UUID().uuidString
}

class SVGMetalRenderer:SVGRenderer {
    var identifier: String = "com.libsvg.renderer.metal"
    var uuid = UUID().uuidString
}
