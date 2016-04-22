//
//  Extension_CALayer.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//
//  Code modified from: Stack Overflow, "Programmatically create a UIView with color gradient"
//	Answer by: Tommie C.
//	Accessed 21 April 2016
//  http://stackoverflow.com/a/31124062/1107226
//

import QuartzCore

extension CALayer {
	
	func configureGradientBackground(withColor color: CGColor) {
		let colorComponents = CGColorGetComponents(color)
		var redComponent = colorComponents[0]
		var greenComponent = colorComponents[1]
		var blueComponent = colorComponents[2]
		let alphaComponent = colorComponents[3]
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		let changePercent: CGFloat = 0.90
		
		redComponent *= changePercent
		greenComponent *= changePercent
		blueComponent *= changePercent
		let color1: CGColor! = CGColorCreate(colorSpace, [redComponent, greenComponent, blueComponent, alphaComponent])
		
		redComponent *= changePercent
		greenComponent *= changePercent
		blueComponent *= changePercent
		let color2: CGColor! = CGColorCreate(colorSpace, [redComponent, greenComponent, blueComponent, alphaComponent])
		
		redComponent *= changePercent
		greenComponent *= changePercent
		blueComponent *= changePercent
		let color3: CGColor! = CGColorCreate(colorSpace, [redComponent, greenComponent, blueComponent, alphaComponent])
		
		configureGradientBackground(color, color1, color2, color3)
	}
	
	
	func configureGradientBackground(colors:CGColor...){
		
		let gradient = CAGradientLayer()
		
		let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
		let squareFrame = CGRect(origin: self.bounds.origin, size: CGSizeMake(maxWidth, maxWidth))
		gradient.frame = squareFrame
		
		gradient.colors = colors
		
		self.insertSublayer(gradient, atIndex: 0)
	}
	
}