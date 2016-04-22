//
//  LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.setGradientLayer(withColor: UIColor.orangeColor())
    }

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		
		// locking this (login view) to portrait since subviews won't all fit on smaller devices in landscape
		return .Portrait
	}

}
