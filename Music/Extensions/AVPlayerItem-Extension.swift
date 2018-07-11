//
//  AVPlayerItem-Extension.swift
//  Music
//
//  Created by Aleksandr on 16.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayerItem {

    var url: URL? {
        if let urlAsset = self.asset as? AVURLAsset {
            return urlAsset.url
        }

        return nil
    }
}
