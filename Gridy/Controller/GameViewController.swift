//
//  GameViewController.swift
//  Gridy

//  Created by Eric Stein on 7/5/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, AVAudioPlayerDelegate {
    
    //MARK: - **************** Variables ****************
    
    // global variable that holds the passed game image
    var gameImage = UIImage()
    // array of images to hold the 16 slices of the game image
    private var imageArray = [UIImage]()
    // array of customed tiles(subclassed from UIImage view) to hold the tiles and their extra attributes
    private var tileViews = [Tiles]()
    // array to hold the top left corner of each tile location in the grid
    private var gridLocations = [CGPoint]()
    
    
    // sound managment variables
    @IBOutlet weak var soundButton: UIButton!
    private var audioPlayer : AVAudioPlayer!
    
    // varaiables for move counter functionality
    @IBOutlet weak var movesCounter: UILabel!
    private var moves = 0
    private var score = 0
    private var scoringreward = 0
    // views for the peek functionality
    private let imageView = UIImageView()
    private let imageHoldingView = UIView()
    
    
    // containing view that contains both subviews of the slices of the game image and the grid views tiles
    @IBOutlet weak var containingView: UIView!
    @IBOutlet weak var gridView: UIImageView!
    @IBOutlet weak var tilesContainerView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    
    
    @IBAction func newGameButton(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func soundButtonPressed(_ sender: Any) {
        // disable and undisable the sound button
        soundButton.isSelected = !soundButton.isSelected
    }
    
    // functionality of the peek image, presenting a preview of the image
    @IBAction func peekButtonPressed(_ sender: Any) {
        //set the view image as the game image
        imageView.image = gameImage
        // add the image holding view to the view
        view.addSubview(imageHoldingView)
        // add the imageview to image holding view
        imageHoldingView.addSubview(imageView)
        // variable to hold the dimension of both image holding view and image view
        var imageViewDimension = 0.0
        var imageHoldingViewDimension = 0.0
        if view.frame.height > view.frame.width {
            imageViewDimension = Double(view.frame.width) - 30
            // make image holding view bigger than image view dimension so the former appears as a frame of the image
            imageHoldingViewDimension = Double(view.frame.width) - 20
        } else {
            // this statement to cover landscape mode
            imageViewDimension = Double(view.frame.height) - 30
            imageHoldingViewDimension = Double(view.frame.height) - 20
        }
        imageHoldingView.frame = CGRect(x: 0.0, y: 0.0, width: imageHoldingViewDimension, height: imageHoldingViewDimension)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageViewDimension, height: imageViewDimension)
        imageHoldingView.backgroundColor = UIColor.black
        imageView.center = imageHoldingView.center
        // starting point, used y coordinate in X to prevent it from appearing in the landscape orientation
        imageHoldingView.center = CGPoint(x: view.center.y - view.frame.width, y: view.center.y)
        view.bringSubviewToFront(imageHoldingView)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.imageHoldingView.center = self.view.center
        })
        UIView.animate(withDuration: 0.4, delay: 2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            // ending point
            self.imageHoldingView.center = CGPoint(x: self.view.center.x + self.view.frame.width, y: self.view.center.y)
        })
    }
    
    // play a sound using the filename passed as a parameter
    func play(sound: String) {
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: "wav"){
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print(error)
            }
            audioPlayer.play()
        }
    }
    
    // rewarding moves counter
    func updateMoveCounter(isItCorrect: Bool) {
        // increase the number of moves
        moves += 1
        // check if the move is correct
        if isItCorrect == false {
            //reseting the scoring reward and remove a point
            scoringreward = 0
            if score > 0 {
                score -= 1
            }
        } else {
            // incrementing the scoring reward and updating the score
            scoringreward += 1
            score += scoringreward
        }
        // update the score label
        movesCounter.text = String(format: "%03d", score)
    }
    
    // function to resize the passed image to prevent slices from being croped out when populated in the tiles, the new image will be passed to sliceImage() func
    func reSize(image: UIImage, newWidth: CGFloat) -> UIImage? {
        // the new width is the grid view width
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
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
    
    func configure() {
        let draw = ViewGrid(drawingView: gridView)
        draw.drawingOn(thisView: gridView)
        rounded(button: newGameButton)
        sliceImage(image: reSize(image: gameImage, newWidth: gridView.frame.width)!)
        getGridLocations()
    }
    
    
    // function to slice the game image into 16 slices
    func sliceImage(image: UIImage) {
        let imageToSlice = image
        // width and height of each slice
        let width = imageToSlice.size.width/4
        let height = imageToSlice.size.height/4
        // Create a scale conversion factor to convert from points to pixles
        let scale = imageToSlice.scale
        for y in 0..<4 {
            for x in 0..<4 {
                UIGraphicsBeginImageContext(CGSize(width: width, height: height))
                let i = imageToSlice.cgImage?.cropping(to: CGRect(x: CGFloat(x)*width*scale, y: CGFloat(y)*height*scale, width: width, height: height))
                let tileImage = UIImage(cgImage: i!)
                imageArray.append(tileImage)
                UIGraphicsEndImageContext()
            }
        }
        makeTiles()
    }
    
    // function to create tiles (imageviews) that holds the 16 slices of the game image
    func makeTiles() {
        let numberOfTiles = 16
        let tileDimension = gridView.frame.height / 4
        let tileDimensionWithGap = tileDimension + 5
        // calculate the number of tiles that can fit across and down in the tile container view
        let columns = Int((tilesContainerView.frame.width / tileDimensionWithGap).rounded(.down))
        let rows    = Int((tilesContainerView.frame.height / tileDimensionWithGap).rounded(.down))
        let numberOfTilesCanFit = columns * rows
        if numberOfTiles > numberOfTilesCanFit {
            print("More tiles than space available")
        } else {
            var imageNumber = 0
            var imagePositionsarray = Array(0...(imageArray.count - 1))
            for y in 0...rows {
                for x in 0...columns {
                    if imageNumber < numberOfTiles {
                        let tileXCoordinate = CGFloat(x) * tileDimensionWithGap
                        let tileYCoordinate = CGFloat(y) * tileDimensionWithGap
                        let tileRect = CGRect(x: tileXCoordinate, y: tileYCoordinate, width: tileDimension, height: tileDimension)
                        let tile = Tiles(originalTileLocation: CGPoint(x: tileXCoordinate, y: tileYCoordinate), frame: tileRect, tileGridLocation: imageNumber)
                        containingView.addSubview(tile)
                        let randomNumber = Int.random(in: 0...(imagePositionsarray.count - 1))
                        let imageIndexNumber = imagePositionsarray.remove(at: randomNumber)
                        tile.image = imageArray[imageIndexNumber]
                        tile.isUserInteractionEnabled = true
                        tile.accessibilityLabel = "\(imageIndexNumber)"
                        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
                        panGestureRecogniser.delegate = self
                        tile.addGestureRecognizer(panGestureRecogniser)
                        tileViews.append(tile)
                    }
                    imageNumber += 1
                }
            }
        }
    }
    
    // global var to hold the initial position of the sliced game image view
    private var initialImageViewOffset = CGPoint()
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        // bring the tile to the front of the view so it doesn't disappear behind other views when moving
        sender.view?.superview?.bringSubviewToFront(sender.view!)
        let translation = sender.translation(in: sender.view?.superview)
        if sender.state == .began {
            initialImageViewOffset = (sender.view?.frame.origin)!
        }
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - (sender.view?.frame.origin.x)!, y: translation.y + initialImageViewOffset.y - (sender.view?.frame.origin.y)!)
        // convert the position to the containing view so we can compare coordinates in the same view with grid locations
        let postionInSuperView = sender.view?.convert(position, to: sender.view?.superview)
        sender.view?.transform = (sender.view?.transform.translatedBy(x: position.x, y: position.y))!
        if sender.state == .ended {
            // getting the dropping position and pass to isTileNearGrid func to check if it's been dropped near any grid view locations
            let (nearTile, snapPosition) = isTileNearGrid(droppingPosition: postionInSuperView!)
            let tile = sender.view as! Tiles
            if nearTile {
                // if near then assing the origin of the slice image view to the location of the grid view that is near
                sender.view?.frame.origin = gridLocations[snapPosition]
                
                // ******************    play correct sound   **********************
                if !soundButton.isSelected  {
                    play(sound: "correct")
                }
                // check if they are in the right position
                if String(snapPosition) == tile.accessibilityLabel {
                    tile.isTileInCorrectLocation = true
                    updateMoveCounter(isItCorrect: true)
                } else {
                    tile.isTileInCorrectLocation = false
                    updateMoveCounter(isItCorrect: false)
                }
            } else {
                // if its not in the correct placement return it to the original location
                sender.view?.frame.origin = tile.originalTileLocation
                tile.isTileInCorrectLocation = false
                
                //  **********************  play wrong sound **********************
                if !soundButton.isSelected {
                    play(sound: "Error")
                }
            }
            GameCompleted()
        }
    }
    
    func GameCompleted() {
        if allTilesInCorrectPosition() {
            performSegue(withIdentifier: "goToFinalViewController", sender: self)
        }
    }
    
    // segue func to pass the game image to FinalViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFinalViewController" {
            let destination = segue.destination as! FinalViewController
            destination.gameImage = gameImage
            destination.moves = moves
            destination.score = score
        }
    }
    
    func allTilesInCorrectPosition() -> Bool {
        for tile in tileViews {
            if tile.isTileInCorrectLocation == false {
                return false
            }
        }
        return true
    }
    
    // check if the dropped location of the image slice is near any of the grid view locations
    func isTileNearGrid(droppingPosition: CGPoint) -> (Bool,Int) {
        for x in 0..<gridLocations.count {
            let gridlocation = gridLocations[x]
            let fromX = droppingPosition.x
            let toX = gridlocation.x
            let fromY = droppingPosition.y
            let toY = gridlocation.y
            let area = (fromX - toX) * (fromX - toX) + (fromY - toY) * (fromY - toY)
            let halfTileSideSize = (gridView.frame.height / 4) / 2
            // comparing areas
            if area < halfTileSideSize * halfTileSideSize {
                // return the index of which that is near and return true
                return(true, x)
            }
        }
        // put 50 just for the sake of returning an Int
        return(false, 50)
    }
    
    // get grid view tiles locations and convert it to the containing view(superview)
    private var locationInSuperview = CGPoint()
    func getGridLocations() {
        let width  = gridView.frame.width / 4
        let height = gridView.frame.height / 4
        for y in 0..<4 {
            for x in 0..<4 {
                UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
                let location = CGPoint.init(x: CGFloat(x) * width, y: CGFloat(y) * height)
                locationInSuperview = gridView.convert(location, to: gridView.superview)
                gridLocations.append(locationInSuperview)
            }
        }
    }
    
}
