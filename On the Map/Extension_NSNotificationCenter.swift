//
//  Extension_NSNotificationCenter.swift
//  On the Map
//
//  Created by leanne on 6/8/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

extension NSNotificationCenter {
	
	/**
	
	Creates and posts a notification to the main thread.
	
	- parameters:
		- notificationName: Notification name to be provided to observers.
		- userInfo: Dictionary of custom information to be provided to observers, or nil if none needed.
	
	*/
	class func postNotificationOnMain(notificationName: String, userInfo: [String: String]?) {
		
		let notification = NSNotification(name: notificationName, object: nil, userInfo: userInfo)
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
}