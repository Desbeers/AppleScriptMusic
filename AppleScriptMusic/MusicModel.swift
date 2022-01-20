//
//  MusicModel.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 16/01/2022.
//

import SwiftUI
import AppleScriptObjC
import iTunesLibrary

// # MARK: The MusicModel class

class MusicModel: ObservableObject {
    /// The shared instance of this MusicModel class
    static let shared = MusicModel()
    /// AppleScriptObjC object for communicating with Music
    var musicBridge: MusicBridge
    /// The Music library
    var musicSongs: [ITLibMediaItem] = []
    /// Info of current playing track; published because in the UI
    @Published var trackInfo = Track()
    /// The current state of Music
    @Published var musicState = MusicState()
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
}

// # MARK: Get all Music songs

extension MusicModel {
    
    /// Get all songs from Music
    /// - Returns: The songs
    func getMusicSongs() -> [ITLibMediaItem] {
        musicSongs = []
        print("Getting Music songs...")
        let iTunesLibrary: ITLibrary
        do {
            iTunesLibrary = try ITLibrary(apiVersion: "1.0")
        } catch {
            print("Error getting Music songs")
            return [ITLibMediaItem]()
        }
        let songs = iTunesLibrary.allMediaItems
        print("Found \(songs.count) songs")
        return songs
    }
    
}

// # MARK: State handling of the Music application

extension MusicModel {

    /// Get the current state of Music
    /// - Note: If Music is not running this function will call itself again
    func getMusicState() async {
        if musicBridge.playerState == 0 {
            Task { @MainActor in
                musicState.status = MusicState.PlayerState(rawValue: 0)!
                trackInfo = Track()
            }
            /// Call ouselfs again to see if Music is running
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await getMusicState()
        } else {
            Task { @MainActor in
                musicState.status = MusicState.PlayerState(rawValue: musicBridge.playerState as? Int ?? 0)!
                musicState.volume = musicBridge.soundVolume.doubleValue
                getTrackInfo()
            }
        }
    }
    
    /// A struct holding all state information
    struct MusicState {
        var status: PlayerState = .unknown
        var running: Bool {
            return status == .unknown || status == .stopped ? false : true
        }
        var volume: Double = 0
        var message: String {
            switch status {
            case .unknown:
                return "Music is not running"
            case .stopped:
                return "Music is not playing"
            case .playing:
                return "Music is playing"
            case .paused:
                return "Music is paused"
            case .fastForwarding:
                return "Music is forwarding"
            case .rewinding:
                return "Music is rewinding"
            }
        }
        enum PlayerState: Int {
            case unknown
            case stopped
            case playing
            case paused
            case fastForwarding
            case rewinding
        }
    }
}

// # MARK: Track information

extension MusicModel {
    
    /// Get info of the current track
    @MainActor func getTrackInfo() {
        var track = Track()
        /// TrackInfo might be nil, so check...
        if musicState.running, let info = musicBridge.trackInfo as NSDictionary? {
            track = Track(dictionary: info)
            track.cover = getTrackCover(track: track)
        }
        /// Update the UI
        trackInfo = track
    }
    
    /// Get the cover for the current track from the Library
    /// - Parameter track: The current ``Track``
    /// - Returns: A Swiftui ``Image``
    private func getTrackCover(track: Track) -> Image {
        var image = Image(systemName: "music.quarternote.3")
        if let match = musicSongs.first(where: {
            $0.title == track.title  &&
            $0.album.title == track.album &&
            $0.trackNumber == track.track
        }) {
            if let coverArt = match.artwork {
                image = Image(nsImage: coverArt.image!)
            }
        }
        return image
    }
}

// # MARK: Actions to send to the MusicBridge

extension MusicModel {
    
    /// Toggle the 'love' button in the UI
    @MainActor func toggleLoved() {
        musicBridge.loved = trackInfo.scriptID
        /// Update the UI
        trackInfo.loved.toggle()
        /// Show Notification
        sendNotification(title: trackInfo.title,
                         message: trackInfo.loved ? "I love this song" : "I don't love this song anymore"
        )
    }

    /// Set the rating of a track in the UI
    /// - Parameter rating: The rating between 0 and 5
    @MainActor func setRating(rating: Int) {
        /// Get the basic Script ID and add the rating value as fifth argument
        musicBridge.rating = trackInfo.scriptID + [NSString(string: "\(rating)")]
        /// Update the UI
        trackInfo.rating = rating
        /// Show Notification
        sendNotification(title: trackInfo.title,
                         message: "I rate this song \(trackInfo.rating) stars"
        )
    }
}

// # MARK: Notification handling

extension MusicModel {
    
    /// Send a notification with AppleScript
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - message: The message of the notification
    private func sendNotification(title: String, message: String) {
        /// Only send a notification is the user wants it
        if UserDefaults.standard.bool(forKey: "showNotifications") {
            musicBridge.notification = [
                title as NSString,
                message as NSString
            ]
        }
    }
}
