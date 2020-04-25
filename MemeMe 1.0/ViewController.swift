//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by BP  Bista on 3/30/20.
//  Copyright © 2020 BP  Bista. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var origialBottomTextPosition:CGFloat!
    var meme:Meme!
    
    // MARK:- Outlests
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var scrollview:UIScrollView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    
    // MARK:- Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupScrollview()
        setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK:- IBActions
    
    @IBAction func share(_ sender: UIBarButtonItem){
        self.save()
        let memeActivityViewController = UIActivityViewController(activityItems: [meme.memedImage] , applicationActivities: nil)
        memeActivityViewController.popoverPresentationController?.sourceView = self.view
        self.present(memeActivityViewController, animated: true, completion: nil)
        
        
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
        scrollview.delegate = self
        //as? UIScrollViewDelegate
    }
    
    func setupTextField(){
        topText.delegate = self
        bottomText.delegate = self
        
        topText.text =  "TOP"
        bottomText.text =  "BOTTOM"
        topText.textAlignment = .center
        bottomText.textAlignment = .center
        
        let font = UIFont.systemFont(ofSize: 40)
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.red
        shadow.shadowBlurRadius = 5
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) ?? font,
            .foregroundColor: UIColor.white,
            .shadow: shadow
        ]
        
        origialBottomTextPosition = bottomText.frame.origin.y
        topText.defaultTextAttributes = attributes
        bottomText.defaultTextAttributes = attributes
        hideTextFields()
    }
    
    
    
    // MARK: Keyboard Notifications
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        //        origialBottomTextPosition = bottomText.frame.origin.y
        bottomText.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        bottomText.frame.origin.y = origialBottomTextPosition
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    // MARK: Utility Methods
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        return memedImage
    }
    
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK: Extensions
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
        showTextFields()
        hideMessage()
    }
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        shareButton.isEnabled = false
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Reset default text if textfield is empty
        if textField.text == "" {
            if textField.tag == 0{
                textField.text = "TOP"
            }else if textField.tag == 1 {
                textField.text = "BOTTOM"
            }
        }else{
            shareButton.isEnabled = true
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func hideTextFields(){
        topText.isHidden = true
        bottomText.isHidden = true
    }
    func showTextFields() {
        topText.isHidden = false
        bottomText.isHidden = false
    }
    
    func hideMessage() {
        messageText.isHidden = true
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagePickerView
    }
}
