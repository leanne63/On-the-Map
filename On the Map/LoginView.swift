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
	
	override class var layerClass : AnyClass {
		
		// return a 'type' or class of CAGradientLayer (Obj-C equivalent is CAGradientLayer.class)
		return CAGradientLayer.self
	}
	
	override func prepareForInterfaceBuilder() {
		// TODO: Do I need to put anything in here? Or, can I remove it?
		// see: http://mhorga.org/2015/11/23/ibdesignable-and-ibinspectable.html
		// and: http://justabeech.com/2014/08/03/prepareforinterfacebuilder-and-property-observers/
		// use, say, when you want certain values, images, whatever to appear in IB while designing this view
		super.prepareForInterfaceBuilder()
		
		print(#function)
	}
	
	
	
}
