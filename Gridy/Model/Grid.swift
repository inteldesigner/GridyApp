//
//  GridDrawer.swift
//  Gridy
//
//  Created by Eric Stein on 6/15/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import Foundation
import UIKit

class Grid {
    
    func drawGrid(context: UIGraphicsImageRendererContext, squareDimension: CGFloat) {
        for row in 0...4 {
            let point = CGPoint(x: CGFloat(row)*(squareDimension/4), y: 0)
            context.cgContext.move(to: point)
            context.cgContext.addLine(to: CGPoint(x: CGFloat(row)*(squareDimension/4), y: squareDimension))
            context.cgContext.strokePath()
        }
        for col in 0...4 {
            let point = CGPoint(x:  0, y:CGFloat(col)*(squareDimension/4))
            context.cgContext.move(to: point)
            context.cgContext.addLine(to: CGPoint(x: squareDimension, y: CGFloat(col)*(squareDimension/4)))
            context.cgContext.strokePath()
        }
    }
    
    
    
}
