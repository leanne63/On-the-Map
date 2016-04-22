//
//  Extension_LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

extension UIView {
	
	
	/**
	
	Generates a 3-color gradient centered on the provided UIColor object, or removes gradient if color argument is nil.
	Takes no action if view's layer is not a CAGradientLayer.
	
	- Parameter withColor: UIColor representing central gradient color OR nil.
	
	*/
	func setGradientLayer(withColor color: UIColor?) {
		
		// make sure the view is using a CAGradientLayer layer vs any other (such as the default CALayer)
		guard let _ = self.layer as? CAGradientLayer else {
			print("\(#function) requires a CAGradientLayer; \(self.dynamicType) has a \(self.layer.dynamicType)")
			return
		}
		
		// if color is nil, just remove any existing gradient colors and return
		guard let color = color else {
			(self.layer as! CAGradientLayer).colors = nil
			return
		}
		
		
		// grab the appropriate values from the UIColor object
		var hue: CGFloat = 0.0
		var saturation: CGFloat = 0.0
		var brightness: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		// set a delta value for use in calculating gradient upper and lower hue values
		let hueDelta: Int = 5
		
		// set a place multiplier for rounding to correct place (eg, 100.0 -> 1.00, 1000.0 -> 1.000)
		let placeMultiplier: CGFloat = 100.0
		
		// convert the hue to an int so we can play with it without float inaccuracies
		let hueAsInt = Int(round(hue * placeMultiplier))
		
		// calculate the upper and lower hue values
		let hueDown: CGFloat = CGFloat(hueAsInt - hueDelta) / placeMultiplier
		let hueUp: CGFloat = CGFloat(hueAsInt + hueDelta) / placeMultiplier
		
		// set up color objects to pass into the setGradientLayer overload
		let color1 = (UIColor.init(hue: hueUp, saturation: saturation, brightness: brightness, alpha: alpha)).CGColor
		let color2 = color.CGColor
		let color3 = (UIColor.init(hue: hueDown, saturation: saturation, brightness: brightness, alpha: alpha)).CGColor
		
		setGradientLayer(withColors: color1, color2, color3)

	}
	
	/**
	
	Generates a gradient with the provided CGColor values, in order top to bottom; or removes gradient if called with no arguments.
	Takes no action if view's layer is not a CAGradientLayer.
	
	- Parameter withColors: List of CGColor objects to be used in generating gradient OR empty.
	
	*/
	func setGradientLayer(withColors colors: CGColor...) {
		
		guard let layer = self.layer as? CAGradientLayer else {
			print("\(#function) requires a CAGradientLayer; \(self.dynamicType) has a \(self.layer.dynamicType)")
			return
		}
		
		layer.colors = colors
	}
	
}
