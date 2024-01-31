//
//  Array+RemoteEmoji.swift
//  Towots
//
//  Created by りん on 27/1/2024.
//

import EmojiText
import Foundation
import TootSDK

extension Array where Element == Emoji {

    /// Creates RemoteEmoji Array from an array of TootSDK Emojis
    /// - Returns: [RemoteEmoji], when the array is one of [Emoji]
    public func remoteEmojis() -> [RemoteEmoji] {
        let remoteEmojis = self.compactMap { emoji -> RemoteEmoji? in
            if let url = URL(string: emoji.url) {
                return RemoteEmoji(shortcode: emoji.shortcode, url: url)
            } else {
                return nil
            }
        }

        return remoteEmojis
    }

}
