//
//  Model.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 16/01/2022.
//

import Foundation
import AppleScriptObjC
import iTunesLibrary

class MusicModel: ObservableObject {
    /// The shared instance of this MusicModel class
    static let shared = MusicModel()
    /// AppleScriptObjC object for communicating with Music
    var musicBridge: MusicBridge
    /// Info of current playing track; published because in the UI
    @Published var trackInfo = Track()
    /// the cover of current song
    var cover: ITLibArtwork?
    /// Value of volume level; published because in the UI
    @Published var soundVolume: Double = 0
    /// The current state of Music
    var playerState: PlayerState {
        return PlayerState(rawValue: musicBridge._playerState as? Int ?? 0)!
    }
    /// Bool if Music is running or not
    var isRunning: Bool {
        return musicBridge._isRunning.boolValue
    }
    /// The Music library
    var musicSongs: [ITLibMediaItem] = []
    /// Init the class
    init() {
        /// AppleScriptObjC setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        //// create an instance of MusicBridge script object for Swift code to use
        let musicBridgeClass: AnyClass = NSClassFromString("MusicBridge")!
        self.musicBridge = musicBridgeClass.alloc() as! MusicBridge
        /// Get all Music songs
        musicSongs = getMusicSongs()
    }
    /// Update track info in the UI
    @MainActor func parseTrack() {
        /// trackInfo might be nil, so check...
        if let info = musicBridge.trackInfo as NSDictionary? {
            trackInfo = Track(dictionary: info)
            if let match = musicSongs.first(where: {
                $0.title == trackInfo.name  &&
                $0.album.title == trackInfo.album &&
                $0.trackNumber == trackInfo.trackNumber
            }) {
                if let coverArt = match.artwork {
                    cover = coverArt
                }
                print(match.title)
            } else {
                print("No match")
            }
        }
    }
    /// Get all songs from Music
    /// - Returns: The songs
    func getMusicSongs() -> [ITLibMediaItem] {
        musicSongs = []
        print("Getting Music songs...")
        let iTunesLibrary: ITLibrary
        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
        } catch {
            print("Error occured!")
            return [ITLibMediaItem]()
        }
        let songs = iTunesLibrary.allMediaItems
        print("Found \(songs.count) songs")
        return songs
    }
    /// Toggle the 'love' button in the UI
    @MainActor func toggleLoved() {
        musicBridge.loved = [
            trackInfo.name as NSString,
            trackInfo.artist as NSString,
            trackInfo.album as NSString,
            NSString(string: "\(trackInfo.trackNumber)")
        ]
        parseTrack()
    }
    /// Set the rating of a track in the UI
    @MainActor func setRating(rating: Int) {
        musicBridge.rating = [
            trackInfo.name as NSString,
            trackInfo.artist as NSString,
            trackInfo.album as NSString,
            NSString(string: "\(trackInfo.trackNumber)"),
            NSString(string: "\(rating)")
        ]
        parseTrack()
    }
    /// The duration of the current track as String
    var trackDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(truncating: musicBridge.trackDuration))!
        return formattedString
    }
}

/// A Struct for track information
struct Track: Equatable {
    var artist: String = ""
    var album: String = ""
    var name: String = ""
    var loved: Bool = false
    var trackNumber: Int = 0
    var trackRating: Int = 0
}

extension Track {
    /// Init the Struct with valuis from the MusicBridge
    init(dictionary: NSDictionary) {
        self.artist = dictionary.value(forKey: "trackArtist") as! String
        self.album = dictionary.value(forKey: "trackAlbum") as! String
        self.name = dictionary.value(forKey: "trackName") as! String
        self.loved = dictionary.value(forKey: "trackLoved") as! Bool
        self.trackNumber = dictionary.value(forKey: "trackNumber") as! Int
        /// Track rating im Music goes from 0 - 100, the UI is using only 5 stars
        self.trackRating = (dictionary.value(forKey: "trackRating") as! Int) / 20
    }
}
