//
//  SVGRenderer.swift
//  libSVG
//
//  Created by Laurent Cerveau on 04/14/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation
import CoreGraphics

protocol SVGRenderer {
    var identifier:String { get }
    
    func render(element:SVGElement, destination:SVGRenderDestination)
}
