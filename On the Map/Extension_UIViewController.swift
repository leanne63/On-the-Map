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
	func presentAlert(_ title: String, message: String, actionTitle: String) {
		
		let alertControllerStyle = UIAlertController.Style.alert
		let alertView = UIAlertController(title: title, message: message, preferredStyle: alertControllerStyle)
		
		let alertActionStyle = UIAlertAction.Style.default
		let alertActionOK = UIAlertAction(title: actionTitle, style: alertActionStyle, handler: nil)
		
		alertView.addAction(alertActionOK)
		
		present(alertView, animated: true, completion: nil)
	}
	
	
	/**
	Displays an alert.
	
	- parameters:
		- title: Text to appear as alert title.
		- message: Text to appear as main alert message.
		- actionTitle: Text to appear for user action (such as "OK")
		- actionHandler: Closure to perform actions upon user response to alert.
	
	*/
	func presentAlert(_ title: String, message: String, actionTitle: String, actionHandler: ((UIAlertAction) -> Void)?) {
		
		let alertControllerStyle = UIAlertController.Style.alert
		let alertView = UIAlertController(title: title, message: message, preferredStyle: alertControllerStyle)
		
		let alertActionStyle = UIAlertAction.Style.default
		let alertAction = UIAlertAction(title: actionTitle, style: alertActionStyle, handler: actionHandler)
		
		alertView.addAction(alertAction)
		
		present(alertView, animated: true, completion: nil)
	}

}
