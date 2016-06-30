//
//  Extension_UIViewController.swift
//  On the Map
//
//  Created by leanne on 6/30/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

extension UIViewController {
	
	/**
	Displays an alert.
	
	- parameters:
		- title: Text to appear as alert title.
		- message: Text to appear as main alert message.
		- actionTitle: Text to appear for user action (such as "OK")
	
	*/
	func presentAlert(title: String, message: String, actionTitle: String) {
		
		let alertControllerStyle = UIAlertControllerStyle.Alert
		let alertView = UIAlertController(title: title, message: message, preferredStyle: alertControllerStyle)
		
		let alertActionStyle = UIAlertActionStyle.Default
		let alertActionOK = UIAlertAction(title: actionTitle, style: alertActionStyle, handler: nil)
		
		alertView.addAction(alertActionOK)
		
		presentViewController(alertView, animated: true, completion: nil)
	}
}