//
//  AdjustImageViewController.swift
//  Gridy
//
//  Created by Eric Stein on 5/3/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // variable that holds the passed image
    var passedImage: UIImage?
    
    @IBOutlet weak var startButton: UIButton!
    // view to hold userChosenImage UIImage view
    @IBOutlet weak var cropImageBoxView: UIView!
    // UIImage view to present the passed image
    @IBOutlet weak var userChosenImage: UIImageView!
    // UIImage view to draw the grid on
    @IBOutlet weak var gridView: UIImageView!
    
    @IBAction func closeButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func startButton(_ sender: Any) {
        performSegue(withIdentifier: "goToGameViewController", sender: self)
        userChosenImage.transform = .identity
    }
    
    // Function to draw a grid on the grid view
    func drawing() {
        // create an image renderer the size of gridView
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: gridView.frame.width, height: gridView.frame.height))
        // create an object from GridDrawer class model
        let gridDrawer = Grid()
        // start a context
        let image = renderer.image { (ctx) in
            // get the right rectangle size for the grid by checking the orientation of the device
            if view.frame.width < view.frame.height {
                // portrait orientation
                let squareDimension = view.frame.width * 0.9
                cropImageBoxView.frame = CGRect(x: (view.frame.width - squareDimension)/2, y: (view.frame.height - squareDimension)/2, width: squareDimension, height: squareDimension)
                // calling the object method drawGrid to draw the grid
                gridDrawer.drawGrid(context: ctx, squareDimension: squareDimension - 1)
                // passing squareDimension - 1 to protect grid lines from being clipped at the edges
            } else {
                // landscape orientation
                let squareDimension = view.frame.height*0.9
                cropImageBoxView.frame = CGRect(x: (view.frame.width - squareDimension)/2, y: (view.frame.height - squareDimension)/2, width: squareDimension, height: squareDimension)
                // passing squareDimension - 1 to protect grid lines from being clipped at the edges
                gridDrawer.drawGrid(context: ctx, squareDimension: squareDimension - 1)
            }
        }
        // populate the gridView view with the rendered image
        gridView.image = image
    }
    
    // Function to take a screenshot the size of cropImageBoxView
    func cropImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cropImageBoxView.bounds.size, false, 0)
        cropImageBoxView.drawHierarchy(in: cropImageBoxView.bounds, afterScreenUpdates: true)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return screenShot
    }
    
    // segue func to pass the game image to GameViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameViewController" {
            let destination = segue.destination as! GameViewController
            destination.gameImage = cropImage()
        }
    }
    
    //     // Function to group all configuration functionality
    func configure() {
        // calling this function to draw the grid
        drawing()
        gestureRecognisres()
        rounded(button: startButton)
        // populate the UIimage view with the passed image
        userChosenImage.image = passedImage
    }
    
    // Function to set up the gestures recognisers
    func gestureRecognisres() {
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action:#selector(moveImageView(_:)))
        userChosenImage.addGestureRecognizer(panGestureRecogniser)
        let rotationGestureRecogniser = UIRotationGestureRecognizer(target: self, action:#selector(rotateImageView(_:)))
        userChosenImage.addGestureRecognizer(rotationGestureRecogniser)
        let pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        userChosenImage.addGestureRecognizer(pinchGestureRecogniser)
        panGestureRecogniser.delegate = self
        rotationGestureRecogniser.delegate = self
        pinchGestureRecogniser.delegate = self
    }
    
    // Function to enable multitouch gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != userChosenImage {
            return false
        }
        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer {
            return false
        }
        return true
    }
    
    // global var to hold the initial position of the userChosenImage UIImage view
    private var initialImageViewOffset = CGPoint()
    // Function to handle moving image functionality
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: userChosenImage.superview)
        if sender.state == .began {
            // storing the initial position
            initialImageViewOffset = userChosenImage.frame.origin
        }
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - userChosenImage.frame.origin.x, y: translation.y + initialImageViewOffset.y - userChosenImage.frame.origin.y)
        userChosenImage.transform = userChosenImage.transform.translatedBy(x: position.x, y: position.y)
    }
    
    // set the rotation functionality
    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        userChosenImage.transform = userChosenImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    // set the zooming functionality
    @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
        userChosenImage.transform = userChosenImage.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    // Function to make Buttons rounded, by creating an object from sructure model and call its method
    func rounded(button: UIButton) {
        var roundedButton = RoundedButton()
        roundedButton.setButton(button)
        roundedButton.rounded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    
    
}



