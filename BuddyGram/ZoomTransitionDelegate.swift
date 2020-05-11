//
//  ZoomTransitionDelegate.swift
//  BuddyGram
//
//  Created by Mac OSX on 5/10/20.
//  Copyright © 2020 Mac OSX. All rights reserved.
//

import UIKit

@objc
protocol ZoomingViewController {
    func zoomingImageView(forTransition: ZoomTransitionDelegate) -> UIImageView?
    func zoomingBackgroundView(forTransition: ZoomTransitionDelegate) -> UIView?
    
}

enum TransitionState {
    case initial
    case final
}

class ZoomTransitionDelegate: NSObject {
    var duration = 0.5
    var operation: UINavigationController.Operation = .none
    
    private let zoomScale = CGFloat(15)
    private let backgroundScale = CGFloat(0.7)
    
    typealias zoomingViews =  (otherView: UIView,imageView: UIView)
    
    func configureViews(for state: TransitionState,containerView: UIView, backgroundVC: UIViewController,viewsInBackground: zoomingViews, viewsInForeground: zoomingViews,snapshotViews: zoomingViews)
    {
        switch state {
        case .initial:
            backgroundVC.view.transform = CGAffineTransform.identity
            backgroundVC.view.alpha = 1
            
            snapshotViews.imageView.frame = containerView.convert(viewsInBackground.imageView.frame, to: viewsInBackground.imageView.superview)
        case .initial:
            backgroundVC.view.transform = CGAffineTransform(scaleX: backgroundScale, y: backgroundScale)
            backgroundVC.view.alpha = 1
            
            snapshotViews.imageView.frame = containerView.convert(viewsInForeground.imageView.frame, to: viewsInForeground.imageView.superview)
        default:
             return
        }
    }
}

extension ZoomTransitionDelegate: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(using: transitionContext)
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let containerView = transitionContext.containerView
        
        var backgroundVC = fromVC
        var foregroundVC = toVC
        
        if operation == .pop {
            backgroundVC = toVC
            foregroundVC = fromVC
        }
        
        
        let maybeBackgroundImageView = (backgroundVC as? ZoomingViewController)?.zoomingImageView(forTransition: self)
        let maybeForegroundImageView = (foregroundVC as? ZoomingViewController)?.zoomingImageView(forTransition: self)
        
        let backgroundImageView = maybeBackgroundImageView!
        let foregroundImageView = maybeForegroundImageView!
        
        let imageViewSnapshot = UIImageView(image: backgroundImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFill
        imageViewSnapshot.layer.masksToBounds = true
        
        backgroundImageView.isHidden = true
        foregroundImageView.isHidden = true
        
        let foregroundViewColor = foregroundVC!.view.backgroundColor
        foregroundVC?.view.backgroundColor = UIColor.clear
        containerView.backgroundColor = UIColor.white
        
        containerView.addSubview(backgroundVC!.view)
        containerView.addSubview(foregroundVC!.view)
        containerView.addSubview(imageViewSnapshot)
        
        var preTransitionState = TransitionState.initial
        var postTransitionState = TransitionState.final
        
        if operation == .pop {
            preTransitionState = TransitionState.final
            postTransitionState = TransitionState.initial
        }
        
        configureViews(for: preTransitionState, containerView: containerView, backgroundVC: backgroundVC!, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
        
        foregroundVC?.view.layoutIfNeeded()
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            self.configureViews(for: postTransitionState, containerView: containerView, backgroundVC: backgroundVC!, viewsInBackground: (backgroundImageView, backgroundImageView), viewsInForeground: (foregroundImageView, foregroundImageView), snapshotViews: (imageViewSnapshot, imageViewSnapshot))
            
        }) { (finished) in
            backgroundVC!.view.transform = CGAffineTransform.identity
            imageViewSnapshot.removeFromSuperview()
            backgroundImageView.isHidden = false
            foregroundImageView.isHidden = false
            foregroundVC?.view.backgroundColor = foregroundViewColor
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}

extension ZoomTransitionDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is ZoomingViewController && toVC is ZoomingViewController {
            self.operation = operation
            return self
        }else {
            return nil
        }
    }
}
