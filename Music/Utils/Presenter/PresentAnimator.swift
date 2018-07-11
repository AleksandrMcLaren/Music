//
//  Animator.swift
//  Music
//
//  Created by Aleksandr on 06.04.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit

class PresentAnimator  {

    public var card: CardViewPresentable!
    public var presenting: Bool!
    public var endAnimation: (() -> Swift.Void)?

    fileprivate var velocity = 0.65
    fileprivate var bounceIntensity: CGFloat = 0.05

    deinit {
        //print("deinit Animator")
    }

    func animateTransition(from: UIViewController, to: UIViewController) {

        guard presenting else {
            // Detail View Controller Dismiss Animations
            card.isPresenting = false

            let presentVC = from as! PresentViewController
            let cardBackgroundFrame = presentVC.view.convert(card.imView.frame, to: nil)
            let bounce = bounceTransform(cardBackgroundFrame, to: presentVC.cardOriginalFrame)

            // Blur and fade with completion
            UIView.animate(withDuration: velocity, delay: 0, options: .curveEaseOut, animations: {
                presentVC.blurView.alpha = 0
                self.card.imView.layer.cornerRadius = self.card.cornerRadius
            }, completion: { _ in
                presentVC.layout(presentVC.cardOriginalFrame, isPresenting: false, isAnimating: false)
                self.card.addSubview(presentVC.cardView.imView)
                from.removeFromParentViewController()
                from.view.removeFromSuperview()
            })

            // Layout with bounce effect
            UIView.animate(withDuration: velocity / 2, delay: 0, options: .curveEaseOut, animations: {
                presentVC.layout(presentVC.cardOriginalFrame, isPresenting: false, transform: bounce)
            }) { _ in
                UIView.animate(withDuration: self.velocity / 2, delay: 0, options: .curveEaseOut, animations: {
                    presentVC.layout(presentVC.cardOriginalFrame, isPresenting: false)
                }
            )}

            return
        }

        // Detail View Controller Present Animations
        card.isPresenting = true

        let presentVC = to as! PresentViewController
        let bounce = self.bounceTransform(presentVC.cardOriginalFrame, to: card.imView.frame)

        presentVC.layout(presentVC.cardOriginalFrame, isPresenting: false)

        // Layout with bounce effect
        UIView.animate(withDuration: velocity / 2, delay: 0, options: .curveEaseOut, animations: {
           presentVC.layout(presentVC.view.frame, isPresenting: true, transform: bounce)
        }) { _ in
            UIView.animate(withDuration: self.velocity / 2, delay: 0, options: .curveEaseOut, animations: {
                presentVC.layout(presentVC.view.frame, isPresenting: true)
            })
        }

        // Blur and fade with completion
        presentVC.blurView.alpha = 0

        UIView.animate(withDuration: velocity, delay: 0, options: .curveEaseOut, animations: {
            self.card.imView.transform = CGAffineTransform.identity    // Reset card identity after push back on tap
            presentVC.blurView.alpha = 1
            self.card.imView.layer.cornerRadius = 0
        }, completion: { _ in
            presentVC.layout(presentVC.cardOriginalFrame, isPresenting: true, isAnimating: false, transform: .identity)
            self.endAnimation?()
        })
    }

    private func bounceTransform(_ from: CGRect, to: CGRect ) -> CGAffineTransform {

        let old = from.center
        let new = to.center

        let xDistance = old.x - new.x
        let yDistance = old.y - new.y

        let xMove = -( xDistance * bounceIntensity )
        let yMove = -( yDistance * bounceIntensity )

        return CGAffineTransform(translationX: xMove, y: yMove)
    }
}

extension CGRect {

    var center: CGPoint {
        return CGPoint(x: width/2 + minX, y: height/2 + minY)
    }
}
