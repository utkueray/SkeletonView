//
//  SkeletonLayer.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 02/11/2017.
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

public typealias SkeletonLayerAnimation = (CALayer) -> CAAnimation

public enum SkeletonType {
    case solid
    case animatedGradient
    case gradient
    
    var layer: CALayer {
        switch self {
        case .solid:
            return CALayer()
        case .animatedGradient:
            return CAGradientLayer()
        case .gradient:
            return CAGradientLayer()
        }
    }
    
    func defaultLayerAnimation(isRTL: Bool) -> SkeletonLayerAnimation? {
        switch self {
        case .solid:
            return { $0.pulse }
        case .animatedGradient:
            return { SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: isRTL ? .rightLeft : .leftRight) }()
        case .gradient:
            return nil
        }
    }
}

struct SkeletonLayer {
    private var maskLayer: CALayer
    private weak var holder: UIView?
    private var defaultDirection = (start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5))
    
    var type: SkeletonType {
        return maskLayer is CAGradientLayer ? .animatedGradient : .solid
    }
    
    var contentLayer: CALayer {
        return maskLayer
    }
    
    init(type: SkeletonType, colors: [UIColor], skeletonHolder holder: UIView, direction: (start: CGPoint, end: CGPoint)?) {
        self.holder = holder
        self.maskLayer = type.layer
        guard let layer = (self.maskLayer as? CAGradientLayer), type == .gradient else {
            self.maskLayer.anchorPoint = .zero
            self.maskLayer.bounds = holder.definedMaxBounds
            self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
            addTextLinesIfNeeded()
            self.maskLayer.tint(withColors: colors)
            return
        }
        
        if holder is UITextView {
            layer.generateGradient(colors: colors.reversed(), direction: direction ?? defaultDirection)
        } else {
            layer.generateGradient(colors: colors, direction: direction ?? defaultDirection)
        }
        
        self.maskLayer.anchorPoint = .zero
        self.maskLayer.bounds = holder.definedMaxBounds
        self.maskLayer.cornerRadius = CGFloat(holder.skeletonCornerRadius)
        addTextLinesIfNeeded()
    }
    
    func update(usingColors colors: [UIColor]) {
        layoutIfNeeded()
        maskLayer.tint(withColors: colors)
    }

    func layoutIfNeeded() {
        if let bounds = holder?.definedMaxBounds {
            maskLayer.bounds = bounds
        }
        updateLinesIfNeeded()
    }
    
    func removeLayer(transition: SkeletonTransitionStyle, completion: (() -> Void)? = nil) {
        switch transition {
        case .none:
            maskLayer.removeFromSuperlayer()
            completion?()
        case .crossDissolve(let duration):
            maskLayer.setOpacity(from: 1, to: 0, duration: duration) {
                self.maskLayer.removeFromSuperlayer()
                completion?()
            }
        }
    }

    /// If there is more than one line, or custom preferences have been set for a single line, draw custom layers
    func addTextLinesIfNeeded() {
        guard let textView = holderAsTextView else { return }
        let lineHeight = textView.constraintHeight ?? SkeletonAppearance.default.multilineHeight
        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
                                                   lineHeight: lineHeight,
                                                   type: type,
                                                   lastLineFillPercent: textView.lastLineFillingPercent,
                                                   multilineCornerRadius: textView.multilineCornerRadius,
                                                   multilineSpacing: textView.multilineSpacing,
                                                   paddingInsets: textView.paddingInsets,
                                                   isRTL: holder?.isRTL ?? false)

        maskLayer.addMultilinesLayers(for: config)
    }
    
    func updateLinesIfNeeded() {
        guard let textView = holderAsTextView else { return }
        let lineHeight = textView.constraintHeight ?? SkeletonAppearance.default.multilineHeight
        let config = SkeletonMultilinesLayerConfig(lines: textView.numLines,
                                                   lineHeight: lineHeight,
                                                   type: type,
                                                   lastLineFillPercent: textView.lastLineFillingPercent,
                                                   multilineCornerRadius: textView.multilineCornerRadius,
                                                   multilineSpacing: textView.multilineSpacing,
                                                   paddingInsets: textView.paddingInsets,
                                                   isRTL: holder?.isRTL ?? false)
        
        maskLayer.updateMultilinesLayers(for: config)
    }
    
    var holderAsTextView: ContainsMultilineText? {
        guard let textView = holder as? ContainsMultilineText,
            (textView.numLines == -1 || textView.numLines == 0 || textView.numLines > 1 || textView.numLines == 1 && !SkeletonAppearance.default.renderSingleLineAsView) else {
                return nil
        }
        return textView
    }
}

extension SkeletonLayer {
    func start(_ anim: SkeletonLayerAnimation? = nil, completion: (() -> Void)? = nil) {
        let animation = anim ?? type.defaultLayerAnimation(isRTL: holder?.isRTL ?? false)
        contentLayer.playAnimation(animation, key: "skeletonAnimation", completion: completion)
    }

    func stopAnimation() {
        contentLayer.stopAnimation(forKey: "skeletonAnimation")
    }
}
