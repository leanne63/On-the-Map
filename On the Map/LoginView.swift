//
//  LoginView.swift
//  On the Map
//
//  Created by leanne on 4/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class LoginView: UIView {
	
	@NSCopying var backgroundGradientColor: UIColor? = nil {
		didSet {
			setGradientLayer(withColor: backgroundGradientColor)
		}
	}

	override class func layerClass() -> AnyClass {
		
		// return a 'type' or class of CAGradientLayer (Obj-C equivalent is CAGradientLayer.class)
		return CAGradientLayer.self
	}
	
	
}
