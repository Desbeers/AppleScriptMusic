//
//  Track.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 19/01/2022.
//

import SwiftUI

/// A Struct for track information
struct Track: Equatable {
    var artist: String = ""
    var album: String = ""
    var title: String = ""
    var loved: Bool = false
    var track: Int = 0
    var duration: String = ""
    var rating: Int = 0
    var cover: Image = Image(systemName: "music.quarternote.3")
    /// Script ID to search for a track with AppleScript
    /// - Note: Persistent ID between AppleScript and iTunesLibrary do not match so can't be used
    var scriptID: [NSString] {
        return [
            title as NSString,
            artist as NSString,
            album as NSString,
            NSString(string: "\(track)")
        ]
    }
}

extension Track {
    /// Init the Struct with values from the MusicBridge
    /// - Note: In an extension so we can still use the memberwise initializer
    /// - Parameter dictionary: The track dicionary returned by the AppleScript
    init(dictionary: NSDictionary) {
        self.artist = dictionary.value(forKey: "trackArtist") as! String
        self.album = dictionary.value(forKey: "trackAlbum") as! String
        self.title = dictionary.value(forKey: "trackName") as! String
        self.loved = dictionary.value(forKey: "trackLoved") as! Bool
        self.track = dictionary.value(forKey: "trackNumber") as! Int
        self.duration = Track.trackDuration(dictionary.value(forKey: "trackDuration") as! NSNumber)
        /// Track rating in Music goes from 0 - 100, the UI is using only 5 stars
        self.rating = (dictionary.value(forKey: "trackRating") as! Int) / 20
    }
}

extension Track {
    /// Convert NSNumber 'seconds' in a time-formatted string
    /// - Parameter duration: NSNumber; teconds of song
    /// - Returns: A formatted tome string
    static func trackDuration(_ duration: NSNumber) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: TimeInterval(exactly: duration)!)!
    }
}
