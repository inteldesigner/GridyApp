//
//  RoundedButton.swift
//  Gridy
//
//  Created by Eric Stein on 5/28/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import Foundation
import UIKit

struct RoundedButton {
    private var button: UIButton?
    
    mutating func setButton(_ button: UIButton) {
        self.button = button
    }
    
    func rounded() {
        if let newButton = button {
            newButton.layer.cornerRadius  = 10.0
            newButton.layer.masksToBounds = true
        }
    }
}
