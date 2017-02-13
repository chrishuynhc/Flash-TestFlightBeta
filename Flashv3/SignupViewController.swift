//
//  SignupViewController.swift
//  Flashv3
//
//  Created by Chris on 12/16/16.
//  Copyright © 2016 Flash. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
   
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 239/255.0, green: 96/255.0, blue: 86/255.0, alpha: 1)
        
        //Join Us! Title
        let logo = UIImage(named: "joinUs")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        //Back Arrow
        let backArrowimage = UIImage(named: "backArrow")
        let backArrow = UIBarButtonItem(image: backArrowimage, style: .plain, target: self, action: #selector(SignupViewController.backButtonHit))
        backArrow.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = backArrow
        
        //White Text Field Container
        view.addSubview(inputsContainerView)
        setupInputsContainerView()
        
    }
    
    @IBAction func popoverOkHit(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func backButtonHit() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupInputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: 81).isActive = true
        inputsContainerView.widthAnchor.constraint(equalToConstant: 345).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 129).isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //Name Text Field Constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //Separator #1 Constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Email Text Field Constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //Separator #2 Constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: passwordTextField.topAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Password Text Field Constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 15).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: inputsContainerView.rightAnchor, constant: 15).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
            
            if (passwordTextField.text!.characters.count < 6){
                
                let alert = UIAlertController(title: "Error", message: "Password must be at least 6 characters.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {
                    user, error in
                    
                    if error != nil{
                        print((error?.localizedDescription.capitalized)! as String)
                        
                        let alert = UIAlertController(title: "Error", message: error?.localizedDescription.capitalized, preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.signupButton.isUserInteractionEnabled = false
                        self.inputsContainerView.isUserInteractionEnabled = false
                        self.inputsContainerView.layer.opacity = 0.3
                        print("User Created")
                        
                        guard let uid = user?.uid else {
                            return
                        }
                        
                        let ref = FIRDatabase.database().reference(fromURL: "https://flash-85846.firebaseio.com/")
                        let usersRef = ref.child("users").child(uid)
                        let values = ["name": self.nameTextField.text!, "email": self.emailTextField.text!, "savedPreferences": 0] as [String : Any]
                        usersRef.updateChildValues(values as [AnyHashable: Any], withCompletionBlock: {
                            (err, ref) in
                            
                            if err != nil{
                                print(err as Any)
                                return
                            }
                            print("Saved Info")
                        })
                        
                        self.performSegue(withIdentifier: "segueContinue", sender: nil)
                    }
                })
            }
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Invalid Email or Password", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        
        view.endEditing(true)
    }
    
    override var  preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    

}
