//
//  CollectionView.swift
//  Music
//
//  Created by Aleksandr on 27.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit
import CoreGraphics

class CollectionView: UIView, PresentCardPresentable {

    public var isSquare = false
    public var object: DBCollection? {
        didSet {
            reloadData()
        }
    }
    /// CardPresentable
    public var isPresenting = false {
        didSet {
            lockLayout = isPresenting
        }
    }
    public var cornerRadius: CGFloat = 10.0
    /// для SliderView
    public var leadingConstant = rowContentInsets.left
    public var trailingConstant = rowContentInsets.right

    fileprivate var imageOriginalFrame: CGRect?
    fileprivate var tap = UITapGestureRecognizer()
    fileprivate var lockLayout = false
    fileprivate var touchesEnded = false
    fileprivate var touchesAnimated = false

    lazy var imView: ImageView = {
        let imView = ImageView()
        imView.layer.cornerRadius = cornerRadius
        addSubview(imView)

        // Tap gesture init
        addGestureRecognizer(tap)
        tap.delegate = self
        tap.cancelsTouchesInView = false

        return imView
    }()

    func convertRect(to view: UIView) -> CGRect {
       // return convert(imView.frame, to: view)
        return convert((imageOriginalFrame ?? imView.frame), to: view)
    }

    deinit {
        print(" ")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        guard lockLayout == false else {
            return
        }

        imView.frame = CGRect(x: leadingConstant,
                              y: rowContentInsets.top,
                              width: bounds.width - (leadingConstant + trailingConstant),
                              height: bounds.height - (rowContentInsets.top + rowContentInsets.bottom))
        imageOriginalFrame = imView.frame
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        configureShadow()
    }

    override func viewColors() {
        backgroundColor = cClear
    }

    fileprivate func reloadData() {
        if let cl = object {
            if isSquare == true {
                imView.urlString =  cl.cover_square
            } else {
                imView.urlString =  cl.cover_wide
            }

            //  descrView.timeLabel.text = album.timeString()
        }
    }

    // MARK: - Animations

    private func pushBackAnimated(completion: (() -> Swift.Void)?) {
        lockLayout = true
        UIView.animate(withDuration: 0.25, animations: {
            self.imView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { (_) in
            completion?()
            self.lockLayout = false
        }
    }

    private func resetAnimated(completion: (() -> Swift.Void)?) {
        lockLayout = true
        UIView.animate(withDuration: 0.2, animations: {
            self.imView.transform = CGAffineTransform.identity
        }) { (_) in
            completion?()
            self.lockLayout = false
        }
    }
}

extension CollectionView: UIGestureRecognizerDelegate {

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded = true

        if self.touchesAnimated == true  {
            AppCoordinator.shared.presentCard(self)
            self.touchesEnded = false
            self.touchesAnimated = false
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetAnimated {
            self.touchesEnded = false
            self.touchesAnimated = false
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesAnimated = false

        self.pushBackAnimated { [unowned self] in
            self.touchesAnimated = true

            if self.touchesEnded == true {
                DispatchQueue.main.async {
                    AppCoordinator.shared.presentCard(self)
                    self.touchesEnded = false
                    self.touchesAnimated = false
                }
            }
        }
    }
}
