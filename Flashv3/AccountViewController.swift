//
//  AccountViewController.swift
//  Flashv3
//
//  Created by Chris on 1/8/17.
//  Copyright © 2017 Flash. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let logo = UIImage(named: "accountTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        let menuImage = UIImage(named: "backArrow")
        let menu = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(dismissView))
        menu.tintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        self.navigationItem.leftBarButtonItem = menu
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        if FIRAuth.auth()?.currentUser?.uid != nil {
            updateUserInfo()
        }

        updateProfileImage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUserInfo() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let profileImageUrl = dictionary["profileImageUrl"] as? String
                
                if profileImageUrl != nil {
                    let url = NSURL(string: profileImageUrl!)
                    URLSession.shared.dataTask(with: url! as URL, completionHandler: {
                        (data, response, error) in
                        
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        DispatchQueue.main.async(execute: {
                            self.profileImage.image = UIImage(data: data!)
                        })
                        
                        
                    }).resume()
                } else {
                    print("No profile image found.")
                }
                
                self.name.text = dictionary["name"] as? String
                self.email.text = dictionary["email"] as? String
                
            }
            
            
        }, withCancel: nil)
    }
    
    func updateProfileImage() {
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        
    }
    
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        uploadImageToFirebase(image: profileImage.image!)
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image:UIImage) {
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.put(uploadData, metadata: nil, completion:
                { (metadata, error) in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    if let image = metadata?.downloadURL()?.absoluteString {
                        let values = ["profileImageUrl": image]
                        self.registerUserIntoDatabase(values: values as [String : AnyObject])
                    }
                    
                    
            })
        }
        
    }
    
    private func registerUserIntoDatabase(values: [String: AnyObject]){
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let uid = user.uid
            
            let ref = FIRDatabase.database().reference(fromURL: "https://flash-85846.firebaseio.com/")
            let usersRef = ref.child("users").child(uid)
            usersRef.updateChildValues(values, withCompletionBlock: {
                (err, ref) in
                
                if err != nil{
                    print(err)
                    return
                }
                print("Added Image")
            })
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
