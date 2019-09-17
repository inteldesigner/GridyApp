//
//  TileAttributes.swift
//  Gridy
//
//  Created by Eric Stein on 7/30/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit

class Tiles: UIImageView, UIGestureRecognizerDelegate {
    
    var originalTileLocation: CGPoint
    // final position in grid 0 - 15
    // access using gridLocations array
    var tileGridLocation: Int
    var isTileInCorrectLocation: Bool
    
    init(originalTileLocation: CGPoint, frame: CGRect, tileGridLocation: Int) {
        self.originalTileLocation = originalTileLocation
        self.tileGridLocation     = tileGridLocation
        isTileInCorrectLocation   = false
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
