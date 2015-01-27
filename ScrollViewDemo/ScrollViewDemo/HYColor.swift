//
//  HYColor.swift
//  ScrollViewDemo
//
//  Created by Harry Yan on 15/1/27.
//  Copyright (c) 2015年  Harry Yan. All rights reserved.
//

import UIKit

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
