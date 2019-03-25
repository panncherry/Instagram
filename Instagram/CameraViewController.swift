//
//  CameraViewController.swift
//  Instagram
//
//  Created by Pann Cherry on 3/20/19.
//  Copyright © 2019 TechBloomer. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onClick_PostButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
        post["caption"] = descriptionField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        post["image"] = file
        
        post.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                self.descriptionField.text = ""
                print("Saved!")
            } else {
                print("Error")
            }
        }
    }

    @IBAction func onClick_CameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate //Let me know when user is done taking photo. Call me back on a func that has the photo
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil) //when tapping on camera btn, show the libaray
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
}

