//
//  Extension_SCNetworkReachability.swift
//  On the Map
//
//  Created by leanne on 6/16/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import SystemConfiguration

extension SCNetworkReachability {
	
	/**
	
	Verify network connection is available.
	
	- parameter urlToReach: URL to be accessed.
	
	- returns: true if network available, false otherwise.
	
	*/
	static func checkIfNetworkAvailable(urlToReach: NSURL) -> Bool {
		
		let host = (urlToReach.absoluteString as NSString).UTF8String
		guard let ref = SCNetworkReachabilityCreateWithName(nil, host) else {
			//Unable to create SCNetworkReachability reference.
			return false
		}
		
		var flags: SCNetworkReachabilityFlags = []
		guard SCNetworkReachabilityGetFlags(ref, &flags) == true && flags.contains(.Reachable) else {
			//Unable to access network."
			return false
		}
		
		// if we're here, this device is connected
		return true
	}

}