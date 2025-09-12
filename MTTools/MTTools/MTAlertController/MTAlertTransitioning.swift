//
//  MTAlertTransitioning.swift
//  MTTools
//
//  Created by Koi on 2025/9/12.
//

import UIKit

class MTAlertTransitioning: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    // MARK: - UI components
    /// 转场样式
    let style: MTAlertController.Style
    
    // MARK: - Intializer
    
    init(style: MTAlertController.Style) {
        self.style = style
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from), let toController = transitionContext.viewController(forKey: .to) else {
            return
        }
        guard let fromView = fromController.view, let toView = toController.view else {
            return
        }
        /// 容器
        let containerView = transitionContext.containerView
        /// 时长
        let duration = transitionDuration(using: transitionContext)
        
        if toController.isBeingPresented {
            // Present
            containerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            containerView.addSubview(toView)
            toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
                toView.transform = .identity
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else if fromController.isBeingDismissed {
            // Dismiss
            var transform: CGAffineTransform
            switch style {
            case .alert:
                transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            case .actionSheet:
                transform = CGAffineTransform(translationX: 0, y: toView.frame.height)
            }
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
                fromView.transform = transform
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
