//
//  Extension_LoginViewController.swift
//  On the Map
//
//  Created by leanne on 4/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

extension LoginViewController {
	
	func setUpViewGradient(withColor color: UIColor) {
		
		let layer = view.layer as! CAGradientLayer
		
		var hue: CGFloat = 0.0
		var saturation: CGFloat = 0.0
		var brightness: CGFloat = 0.0
		var alpha: CGFloat = 0.0
		
		color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		
		let color1 = UIColor.init(hue: hue + 0.020, saturation: saturation, brightness: brightness, alpha: alpha)
		let color2 = UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		let color3 = UIColor.init(hue: hue - 0.010, saturation: saturation, brightness: brightness, alpha: alpha)
		
		
		layer.colors = [color1.CGColor, color2.CGColor, color3.CGColor]

	}
}
