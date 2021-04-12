// Copyright © 2018 SkeletonView. All rights reserved.

import UIKit

/// Used to store all config needed to activate the skeleton layer.
struct SkeletonConfig {
    /// Type of skeleton layer
    let type: SkeletonType
    
    /// Colors used in skeleton layer
    let colors: [UIColor]
    
    /// If type is gradient, which gradient direction
    let gradientDirection: GradientAnimationDirection?
    
    /// Specify if skeleton is animated or not
    let animated: Bool
    
    /// Used to execute a custom animation
    let animation: SkeletonLayerAnimation?
    
    ///  Transition style
    var transition: SkeletonTransitionStyle
    
    /// Custom Direction
    var customDirection: (start: CGPoint, end: CGPoint)?
    
    init(type: SkeletonType,
         colors: [UIColor],
         gradientDirection: GradientAnimationDirection? = nil,
         customDirection: (start: CGPoint, end: CGPoint)? = nil,
         animated: Bool = false,
         animation: SkeletonLayerAnimation? = nil,
         transition: SkeletonTransitionStyle = .crossDissolve(0.25)) {
        self.type = type
        self.colors = colors
        self.gradientDirection = gradientDirection
        self.animated = animated
        self.animation = animation
        self.transition = transition
        self.customDirection = customDirection
    }
}
