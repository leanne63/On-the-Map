//
//  Login.swift
//  On the Map
//
//  Created by leanne on 5/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

/**

Represents On the Map login-related data.

*/
struct Login {
	
	// MARK: - Constants
	
	let sessionIdChanged = "sessionIdChanged"
	let sessionIdKey = "sessionIdKey"
	
	
	// MARK: - Properties
	
	/**
	
	Retrieved on successful login.
	
	*/
	var sessionId: String? {
		didSet {
			var userInfo: [String: String]?
			if let sessionId = sessionId {
				userInfo = [sessionIdKey: sessionId]
			}
			
			// post notification for observers
			let notification = NSNotification(name: sessionIdChanged, object: nil, userInfo: userInfo)
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
	
	// MARK: - Functions
	
	func login() {
		// TODO: POST request to get session id
		// https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
		print("IN: \(#function)")
	}

	func logout() {
		// TODO: DELETE request with session id
		print("IN: \(#function)")
	}

}
