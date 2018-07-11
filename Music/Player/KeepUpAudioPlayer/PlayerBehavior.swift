//
//  Behavior.swift
//  Music
//
//  Created by Aleksandr on 29.03.2018.
//  Copyright © 2018 Aleksandr. All rights reserved.
//

import Foundation

class PlayerBehavior {

    weak var player: KeepUpAudioPlayer!

    /// Если включен повтор одного item, выполняет повтор, возвращает true. Иначе возвращает false.
    func repeatModeOnce() -> Bool {

        if player.repeatMode == .once {
            let currentIndex = player.state.currentIndex
            player.fetchItemsAndPlay(at: currentIndex)
            return true
        }

        return false
    }

    /// Если включен повтор items, выполняет повтор items, возвращает true. Иначе возвращает false.
    func repeatModeOn() -> Bool {

        if player.repeatMode == .on, player.state.currentIndex == player.lastItemIndex {
            player.fetchItemsAndPlay(at: 0)
            return true
        }

        return false
    }

    func shuffleModeOn(playNow: Bool) -> Bool {

        if player.shuffleMode == .off {
            return false
        }

        let nextIndex = shuffleIndex()

        if nextIndex != kCFNotFound {

            if playNow == true {

                if player.state.needsPlaying == true {
                    let index = player.playerCurrentIndex()
                    /// если плеер не смог воспроизвести item
                    /// если item переключили до воспроизведения через playNext:
                    /// добавим индекс в список воспроизведенных здесь
                    if player.shufflePlayedIndexes.contains(index) == false {
                        player.shufflePlayedIndexes.append(index)
                    }
                }

                /// включим воспроизведение
                player.fetchItemsAndPlay(at: nextIndex)
            } else {
                /// подгрузим следующий item
                player.fetchItemAtIndex(nextIndex)
            }

        } else {

            if player.shufflePlayedIndexes.count == (player.lastItemIndex + 1),
                player.state.currentTime >= player.state.currentDuration {
                /// закончил играть последний item
                player.pause()
                player.shufflePlayedIndexes.removeAll()
            }
        }

        return true
    }

    func previousShuffleModeOn() -> Bool {

        if player.shuffleMode == .off {
            return false
        }

        let playerIndex = player.playerCurrentIndex()
        if let shuffleIndex = player.shufflePlayedIndexes.index(of: playerIndex), shuffleIndex > 0 {
            /// найдем предыдущий индекс shuffleIndex
            let index = player.shufflePlayedIndexes[(shuffleIndex - 1)]
            /// удалим текущий индекс shuffleIndex, сгенерируется новый
            player.shufflePlayedIndexes.remove(at: shuffleIndex)
            player.fetchItemsAndPlay(at: index)
        } else {
            player.seek(to: 0)
        }

        return true
    }

    func shuffleIndex() -> Int {

        let countItems = player.lastItemIndex + 1

        if player.shufflePlayedIndexes.count == countItems {
            /// все индексы проиграны
            if player.repeatMode == .off {
                return kCFNotFound
            } else {
                player.shufflePlayedIndexes.removeAll()
            }
        }

        var nextIndex = 0

        while player.shufflePlayedIndexes.contains(nextIndex) {
            nextIndex = Int(arc4random()) % countItems
        }

        return nextIndex
    }
}
