//
//  ImageView.swift
//  Music
//
//  Created by Aleksandr on 30.01.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import UIKit
import Kingfisher

class ImageView: UIImageView {

    deinit {
       // print(" ")
    }

    var urlString: String? {
        willSet {
            if urlString == nil || urlString != newValue {
                prepareLoadImage()
                setNeedsLayout()
            }
        }
    }

    var defaultImage: UIImage?

    fileprivate var imageLoading: Bool = false
    fileprivate var imageUrl: URL?

    fileprivate func prepareLoadImage() {
        self.image = nil
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        imageUrl = nil
        imageLoading = false
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if imageLoading == false {
            let boundsSize = bounds.size
            DispatchQueue.global(qos: .utility).async {
                self.loadImage(with: boundsSize)
            }
        }
    }

    override func viewColors() {
        backgroundColor = cBackground
    }

    fileprivate func loadImage(with size: CGSize) {

        imageUrl = API.shared.imageUrl(with: urlString, width: size.width, height: size.height)

        guard let imageUrl = imageUrl else {
            return
        }

        imageLoading = true
        KingfisherManager.shared.retrieveImage(with: imageUrl,
                                               options: nil,
                                               progressBlock: nil,
                                               completionHandler: { [weak self] image, error, cacheType, imageURL in
                                                DispatchQueue.main.async {
                                                    if let _self = self {
                                                        if imageURL == _self.imageUrl {
                                                            if let image = image {
                                                                if cacheType.cached == true {
                                                                    _self.image = image
                                                                } else {
                                                                    _self.fadeImage(image, diration: 0.4)
                                                                }
                                                            } else if let defaultImage = _self.defaultImage {
                                                                _self.fadeImage(defaultImage, diration: 0.4)
                                                            }
                                                        }
                                                    }
                                                }
        })
    }

    fileprivate func fadeImage(_ image: UIImage, diration: CFTimeInterval) {
        //let transition = CATransition()
        //transition.duration = diration
        //transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //transition.type = kCATransitionFade
        //self.layer.add(transition, forKey: nil)

        UIView.transition(with: self,
                          duration: diration,
                          options: .transitionCrossDissolve,
                          animations: { self.image = image },
                          completion: nil)
    }
}
