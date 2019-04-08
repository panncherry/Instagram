//
//  LogInViewController.swift
//  Instagram
//
//  Created by Pann Cherry on 3/20/19.
//  Copyright © 2019 TechBloomer. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*:
     # Sign in
     * Check user authentications upon sign in
     */
    @IBAction func onClicked_SignInButton(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "logInSegue", sender: nil)
            } else {
                print("Error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
    /*:
     # Sign up
     * Create new account
     */
    @IBAction func onClicked_SignUpButton(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "logInSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            } else {
                print("Sign up error \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
}
