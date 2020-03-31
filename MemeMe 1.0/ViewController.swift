//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by BP  Bista on 3/30/20.
//  Copyright © 2020 BP  Bista. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var scrollview:UIScrollView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    setupScrollview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Setup Methods

    func setupScrollview(){
        scrollview.minimumZoomScale = 0.1
        scrollview.maximumZoomScale = 4.0
        scrollview.zoomScale = 1.0
        scrollview.delegate = self as? UIScrollViewDelegate
    }

}


extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.endEditing(true)
            print("picked")
            imagePickerView.contentMode = .scaleAspectFill
        }
        dismiss(animated: true, completion: nil)
    }
}
    extension ViewController: UIScrollViewDelegate {
        func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
            return imagePickerView
        }
    }
    


