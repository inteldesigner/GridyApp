//
//  CompleteShareViewController.swift
//  Gridy
//
//  Created by Eric Stein on 9/02/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {
    
    var gameImage = UIImage()
    var moves = Int()
    var score = Int()
    
    //variables
    @IBOutlet weak var completeImageHolder: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
  
    
    @IBAction func newGameButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        // define content to share
        let note = "Congratulation!"
        let image = gameImage
        let items = [note as Any, image as Any]
        // create activity view controller
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = view
        // present the view controller
        present(activityController, animated: true)
    }
//    Make better button for presentation
    func rounded(button: UIButton) {
        var roundedButton = RoundedButton()
        roundedButton.setButton(button)
        roundedButton.rounded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rounded(button: newGameButton)
        rounded(button: shareButton)
        
        //set finished game label using score and moves
        scoreLabel.text = "The puzzle was solved in \(moves) moves and you scored \(score) points"
        //set image view as game image
        completeImageHolder.image = gameImage
    }
    
    
   
}
