//
//  Extensions.swift
//  euler8
//
//  Created by Marten Saflund on 2016-08-17.
//  Copyright © 2016 Far East Asia Development Co. Ltd. All rights reserved.
//

import UIKit


/**
 Returns a scaled CGRect that maintains the aspect ratio specified by a CGSize within a bounding CGRect. Replacement for AVMakeRect().
 - parameter aspectRatio:   The width and height ratio (aspect ratio) you want to maintain.
 - parameter boundingRect:  The bounding rectangle you want to fit into.
 */
func makeAspectRect(_ aspectRatio: CGSize, insideRect boundingRect: CGRect) -> CGRect {
    var rect = CGRect(origin: CGPoint(x: 0, y: 0), size: aspectRatio)
    let ratio = aspectRatio.width / aspectRatio.height
    
    if boundingRect.size.width / boundingRect.size.height < ratio {
        rect.size.width = boundingRect.size.width
        rect.size.height = boundingRect.size.width * 1 / ratio
    }
    else {
        rect.size.width = boundingRect.size.height * ratio
        rect.size.height = boundingRect.size.height
    }
    
    return rect
}

