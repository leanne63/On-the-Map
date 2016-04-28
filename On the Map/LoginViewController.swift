//
//  LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	// MARK: - Properties
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		
		// locking this login view to portrait since subviews won't all fit on smaller devices in landscape
		return .Portrait
	}
	
	
	// MARK: - Actions
	
	@IBAction func loginClicked(sender: UIButton) {
		
		print("Login button was clicked. Sender: \(sender)")
	}

}
