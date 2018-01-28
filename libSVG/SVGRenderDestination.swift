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
import CoreServices
#elseif os(iOS)
import UIKit
import MobileCoreServices
#endif

enum SVGRenderDestinationType{
    case view, layer, file
}

class SVGRenderDestination
{
    var type:SVGRenderDestinationType
    var uuid:String
    var destination:Any?
    var uttype:String?
        //File or URL
    var imageIODestination:CGImageDestination?
    
    init?(destination:Any? = nil, attributes:[String:Any]? = nil) {
        self.uuid = UUID().uuidString
        
        if let destinationString = destination as? String {
            self.destination = destination
            self.type = .file
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: self.destination as! String).deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
            
            let destinationURL = URL(fileURLWithPath: destinationString)
            print(destinationURL.pathExtension as CFString)
           // let destinationUTI:CFString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, destinationURL.pathExtension as CFString, nil) as! CFString
            
            self.imageIODestination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: destinationString) as CFURL, kUTTypePNG, 1, nil)
        } else if let _ = destination as? URL {
            self.destination = destination
            self.imageIODestination = CGImageDestinationCreateWithURL(self.destination as! CFURL, kUTTypePNG, 1, nil)
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
    
    deinit {
        switch self.type {
        case .file:
            CGImageDestinationFinalize(self.imageIODestination!)
        default:
            print("lala")
        }
    }
}
