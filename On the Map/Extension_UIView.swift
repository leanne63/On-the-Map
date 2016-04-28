//
//  Extension_UIView.swift
//  On the Map
//
//  Created by leanne on 4/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//
//  NOTE: as of this date, Xcode won't display arrays marked as @IBInspectable.
//  I can change the array property to represent individual settings, but then
//	I'd have to limit the number of colors used in the gradient. I'd rather not
//  do that.
//

import UIKit

extension UIView {
	
	// MARK: - Properties
	// (extensions require computed properties; stored properties not allowed)
	
	/**
	
	The colors used in this view's layer, if layer is CAGradientLayer.
	
	*/
	var gradientLayerColors: [UIColor]? {
		
		get {
			if let layer = (self.layer as? CAGradientLayer),
				let layerColors = layer.colors {
				
				var uiColors = [UIColor]()
				for (indexVal, cgColor) in layerColors.enumerate() {
					let thisColor = UIColor.init(CGColor: cgColor as! CGColor)
					uiColors.insert(thisColor, atIndex: indexVal)
				}
				return uiColors
			}
			else {
				return nil
			}
		}
		
		set {
			if let layer = self.layer as? CAGradientLayer {
				
				var cgColors: [CGColor]? = nil
				
				if let uiColors = newValue {
					cgColors = gradientColorsFromUIColors(uiColors)
				}
				
				layer.colors = cgColors
			}
		}
	}
	
	
	// MARK: - Private Functions
	
	/**
	
	Converts UIColors to CGColors for use in CAGradientLayer. If only one UIColor provided, generates 3-color array with provided color as center value, preceded by lighter color and followed by darker color.
	
	- Parameter colors: An array of UIColors in order, top to bottom, for the desired gradient.
	
	- Returns: Array of CGColors for the provided UIColors (including generated colors if only one UIColor was provided).
	
	*/
	private func gradientColorsFromUIColors(colors: [UIColor]) -> [CGColor] {
		
		var gradientColors = [CGColor]()
		
		// if only one color present, use it as center color, and compute top and bottom colors
		if colors.count == 1 {
			let color = colors[0]
			
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
			let hueUp: CGFloat = CGFloat(hueAsInt + hueDelta) / placeMultiplier
			let hueDown: CGFloat = CGFloat(hueAsInt - hueDelta) / placeMultiplier
			
			// set up color objects to pass into the setGradientLayer overload
			let color1 = (UIColor.init(hue: hueUp, saturation: saturation, brightness: brightness, alpha: alpha))
			let color2 = color
			let color3 = (UIColor.init(hue: hueDown, saturation: saturation, brightness: brightness, alpha: alpha))
			
			gradientColors = [color1.CGColor, color2.CGColor, color3.CGColor]
		}
		else {
			// if multiple colors provided, use those
			// enumerate via index as colors are expected to be in order of arguments provided
			for (indexVal, color) in colors.enumerate() {
				gradientColors.insert(color.CGColor, atIndex: indexVal)
			}
		}
		
		return gradientColors
		
	}
	
}
