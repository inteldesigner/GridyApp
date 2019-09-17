//
//  ViewController.swift
//  Gridy
//
//  Created by Eric Stein on 4/6/19.
//  Copyright © 2019 Eric Stein. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

// Delegets for navigation and image picker controller to allow our view controller to handle the outcome of imagePickerController
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // ** Buttons outlets ** to round their corners using RoundedButton model
    @IBOutlet weak var gridyPickButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    
    // ** Variables **
    
    // Global array of images to hold local images
    var localImages = [UIImage]()
    // defaults object to save a reference of the index of the last image picked randomly
    let defaults = UserDefaults.standard
    // image variable to hold the user chosen image
    var userChosenImage = UIImage()
    
    // ** Buttons **
    @IBAction func gridyPick(_ sender: Any) {
        pickRandom()
    }
    @IBAction func cameraPick(_ sender: Any) {
        displayCamera()
    }
    @IBAction func libraryPick(_ sender: Any) {
        displayLibrary()
    }
    
    //MARK: - ******************Camera and photo library functions******************
    
    //check the access and status to the photo camera before loading the view
    func displayCamera() {
        // setting the source type for image picker controller
        let sourceType = UIImagePickerController.SourceType.camera
        // check wether or not the sourcetype is available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            // no permission prompt - message if no access
            let noPermissionMessage = "Gridy does not have access to use your camera. Please go to Settings>Gridy>Camera on your device to allow Gridy to use your Camera"
            // checking and getting current status of camera access
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            //if there is no permission set, request permission
            case .notDetermined :
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                    if granted {
                        // if permission granted then call presentPhoto func to present the camera
                        self.presentPhoto(sourceType: sourceType)
                    } else {
                         //if permission denied call function that presents alert message to user
                        self.troubleAlert(message: noPermissionMessage)
                    }
                }
            case .authorized :
                // if permission is already granted before, then call presentPhoto func to present the camera
                self.presentPhoto(sourceType: sourceType)
            case .denied, .restricted :
                // if permission denied or restricted call the func that prompts the user with an alert message
                self.troubleAlert(message: noPermissionMessage)
            default:
                // default case to handle all the unknown cases, if any raises then prompt the user with an alert message
                troubleAlert(message: "Sincere apologies, it looks like we can't access your camera at this time")
            }
        } else {
            // if the sourcetype isn't available for any reason, prompts the user with an alert message so to make the user aware that there's something wrong rather than leave them puzzled
            troubleAlert(message: "Sincere apologies, it looks like we can't access your camera at this time")
        }
    }
    
    
    //check the access and status to the photo library before loading the view
    func displayLibrary() {
        // setting the source type for image picker controller
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        // check wether or not the sourcetype is available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
//            message if no access
            let noPermissionMessage = "Gridy does not have access to use your photos. Please go to Settings>Gridy>Photos on your device to allow Gridy to use your photo library"
            // checking and getting current status of camera access
            let status = PHPhotoLibrary.authorizationStatus()
            //if there is no permission set, request permission
            switch status {
            case .notDetermined :
                PHPhotoLibrary.requestAuthorization { (granted) in
                    if granted == .authorized {
                        // if permission granted then call presentPhoto func to present the photo library
                        self.presentPhoto(sourceType: sourceType)
                    } else {
                         //if permission denied call function that presents alert message to user
                        self.troubleAlert(message: noPermissionMessage)
                    }
                }
            case .authorized :
                // if permission is already granted before, then call presentPhoto func to present the photo library
                self.presentPhoto(sourceType: sourceType)
            case .denied, .restricted :
                // if permission denied or restricted call the func that prompts the user with an alert message
                self.troubleAlert(message: noPermissionMessage)
            default:
                // default case to handle all the unknown cases, if any raises then prompt the user with an alert message
                troubleAlert(message: "Sincere apologies, it looks like we can't access your photo library at this time")
            }
        } else {
            // if the sourcetype isn't available for any reason, prompts the user with an alert message so to make the user aware that there's something wrong rather than leave them puzzled
            troubleAlert(message: "Sincere apologies, it looks like we can't access your photo library at this time")
        }
    }
    
    // Function to present camera or photo library
    func presentPhoto(sourceType: UIImagePickerController.SourceType) {
        //open a photo library view for the user to choose an image
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        //present the photo library
        photoPicker.sourceType = sourceType
        present(photoPicker, animated: true)
    }
    
    // Function to present an alert message if there is a problem with the camera or photo library
    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // Delegate method to handle the picked image -
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let pickedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided with the following: \(info)")
        }
        userChosenImage = pickedImage
        performSegue(withIdentifier: "goToEditorImage", sender: self)
    }
    
    // Delegate method to handle the situation when the user cancel picking image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ****************Gridy random pick****************
    
    // Function to collect local images
    func collectLocalImages() {
        //put all the Gridy standard images into an image set
        localImages.removeAll()
        let localImagesNames = ["Bridge", "Sailboat", "oldtimer", "Kitchen", "desert", "Asia"]
        for name in localImagesNames {
            if let image = UIImage(named: name) {
                localImages.append(image)
            }
        }
    }
    
    // Global constant that holds the key for lastImageIndex, created to make it lesser prone to errors
    private let localImageIndex = "imageIndex"
    // calculated variable to store the index(Integer value) of the last randomly picked image from the array localImages
    private var lastImageIndex: Int {
        get {
            let savedIndex = defaults.value(forKey: localImageIndex)
            if savedIndex == nil {
                // initially assign the savedIndex the last index of the last image in localImages
                defaults.set(localImages.count - 1, forKey: localImageIndex)
            }
            return defaults.integer(forKey: localImageIndex)
        }
        set {
            // make sure that the value taht we're trying to pass is between zero and the last index of localImages elements, and if it is within the range then we're saving the value we're provided
            if newValue >= 0 && newValue < localImages.count {
                defaults.set(newValue, forKey: localImageIndex)
            }
        }
    }
    
    // Function to randomly pick a local image to return the random image from the image set
    func randomImage() -> UIImage? {
        let lastPickedImage = localImages[lastImageIndex]
        // make sure that the randomly picked image isn't as the last picked one
        if localImages.count > 0 {
            while true {
                let randomImageNumber = Int.random(in: 0...localImages.count - 1)
                let newImage = localImages[randomImageNumber]
                if newImage != lastPickedImage {
                    lastImageIndex = randomImageNumber
                    return newImage
                }
            }
        }
        return nil
    }
    
    // populate the userChosenImage variable with the randomly picked image to pass it to AdjustImageViewController
    func pickRandom() {
        userChosenImage = randomImage() ?? localImages[0]
        performSegue(withIdentifier: "goToEditorImage", sender: self)
    }
    
    // MARK: - *****Configuration functionality*****
    
    // Function to make Buttons rounded, by creating an object from sructure model and call its method
    func rounded(button: UIButton) {
        var roundedButton = RoundedButton()
        roundedButton.setButton(button)
        roundedButton.rounded()
    }
    
    // Function to group all configuration functionality
    func configure() {
        collectLocalImages()
        
        rounded(button: gridyPickButton)
        rounded(button: CameraButton)
        rounded(button: libraryButton)
        
    }
    
    // segue function to pass the user chosen image to EditorViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditorImage" {
            let destination = segue.destination as! EditorViewController
            destination.passedImage = userChosenImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    
}

