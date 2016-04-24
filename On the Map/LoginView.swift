//
//  LoginView.swift
//  On the Map
//
//  Created by leanne on 4/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

@IBDesignable
class LoginView: UIView {
	
	// MARK: - Properties
	
	/**

	Color to use as the center for a generated background gradient.
	
	*/
	@IBInspectable var gradientColor: UIColor? = nil {
		didSet {
			if let centerGradientColor = gradientColor {
				gradientColors = [centerGradientColor]
			}
			else {
				gradientColors = nil
			}
		}
	}
	
	/**
	
	Colors for the CAGradientLayer gradient or nil if none set.
	
	*/
	var gradientColors: [UIColor]? {
		set {
			gradientLayerColors = newValue
		}
		
		get {
			return gradientLayerColors
		}
	}
	
	
	// MARK: - Overrides
	
	override class func layerClass() -> AnyClass {
		
		// return a 'type' or class of CAGradientLayer (Obj-C equivalent is CAGradientLayer.class)
		return CAGradientLayer.self
	}
	
	override func prepareForInterfaceBuilder() {
		print(#function)
	}
	
	
	
}
