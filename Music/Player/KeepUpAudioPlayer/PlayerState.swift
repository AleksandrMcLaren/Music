//
//  PlayerState.swift
//  Music
//
//  Created by Aleksandr on 15.02.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

struct PlayerState {
    var currentIndex: Int = 0
    var currentTime: Float64 = 0
    var currentDuration: Float64 = 0
    var needsPlaying: Bool = false
    var repeatMode: KeepUpAudioPlayerRepeatMode = .off
    var shuffleMode: KeepUpAudioPlayerShuffleMode = .off
    var lock: Bool = false
    var timedMetadataValue: String = ""

    mutating func reset() {
        currentIndex = 0
        currentTime = 0
        currentDuration = 0
        needsPlaying = false
        lock = false
    }
}
