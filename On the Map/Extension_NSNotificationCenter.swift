//
//  Extension_NSNotificationCenter.swift
//  On the Map
//
//  Created by leanne on 6/8/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

extension NotificationCenter {
	
	/**
	
	Creates and posts a notification to the main thread.
	
	- parameters:
		- notificationName: Notification name to be provided to observers.
		- userInfo: Dictionary of custom information to be provided to observers, or nil if none needed.
	
	*/
	class func postNotificationOnMain(_ notificationName: String, userInfo: [String: String]?) {
		
		let notification = Notification(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
		
		OperationQueue.main.addOperation {
			NotificationCenter.default.post(notification)
		}
	}
}
