//
//  Extension_CALayer.swift
//  On the Map
//
//  Created by leanne on 4/20/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import QuartzCore

extension CALayer {
	
	
	func configureGradientBackground(colors:CGColorRef...){
		
		let gradient = CAGradientLayer()
		
		let maxWidth = max(self.bounds.size.height,self.bounds.size.width)
		let squareFrame = CGRect(origin: self.bounds.origin, size: CGSizeMake(maxWidth, maxWidth))
		gradient.frame = squareFrame
		
		gradient.colors = colors
		
		self.insertSublayer(gradient, atIndex: 0)
	}
	
}