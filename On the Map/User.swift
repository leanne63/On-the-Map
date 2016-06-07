//
//  User.swift
//  On the Map
//
//  Created by leanne on 5/5/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

/**

Represents On the Map user-related data.

*/
struct User {
	
	var userAccountId: String?
	var userFirstName: String?
	var userLastName: String?
	var userNickname: String?
	
	func getUserInfo() {
		// TODO: GET request to retrieve user info
		print("IN: \(#function)")
	}
	
}
