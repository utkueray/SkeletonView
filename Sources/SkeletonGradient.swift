//
//  SkeletonGradient.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 05/11/2017.
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

public struct SkeletonGradient {
    private let gradientColors: [UIColor]
    
    public var colors: [UIColor] {
        return gradientColors
    }
    
    public init(baseColor: UIColor, secondaryColor: UIColor? = nil, repeatColors: Bool? = false) {
        if let secondary = secondaryColor {
            self.gradientColors = repeatColors == true ? [baseColor, secondary, baseColor] : [baseColor, secondary]
        } else {
            self.gradientColors = baseColor.makeGradient()
        }
    }
}
