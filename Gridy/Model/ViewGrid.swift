//
//  DrawingRenderer.swift
//  Gridy
//
//  Created by Eric Stein on 6/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import Foundation
import UIKit

class ViewGrid: Grid {
    
    let drawingView: UIImageView
    
    init(drawingView: UIImageView) {
        self.drawingView = drawingView
    }
    
    func drawingOn(thisView: UIImageView) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: thisView.frame.width, height: thisView.frame.height))
        let image = renderer.image { (ctx) in
            let squareDimension = thisView.frame.width
            drawGrid(context: ctx, squareDimension: squareDimension)
        }
        thisView.image = image
    }
    
}

