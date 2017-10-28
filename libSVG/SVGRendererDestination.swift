//
//  SVGRendererDestination.swift
//  libSVG
//
//  Created by Laurent Cerveau on 06/04/2017.
//  Copyright © 2017 MMyneta. All rights reserved.
//

import Foundation
import ImageIO

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

enum SVGRenderDestinationType{
    case view, layer, file
}

class SVGRenderDestination
{
    var type:SVGRenderDestinationType
    var uuid:String?
    var destination:Any?
    
    
    
    init?(destination:Any? = nil, attributes:[String:Any]? = nil) {
        self.uuid = UUID().uuidString
        
        if let _ = destination as? String {
            self.destination = destination
            self.type = .file
        } else if let _ = destination as? URL {
            self.destination = destination
            self.type = .file
        } else if let _ = destination as? CALayer {
            self.destination = destination
            self.type = .layer
        } else {
    #if os(macOS)
            if let _ = destination as? NSView {
                self.destination = destination
                self.type = .view
            } else {
                return nil
            }
    #elseif os(iOS)
            if let _ = destination as? UIView {
                self.destination = destination
                self.type = .view
            } else {
                return nil
            }
    #endif
        }
    }
}
