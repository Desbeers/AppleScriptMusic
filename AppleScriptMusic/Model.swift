//
//  Model.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 16/01/2022.
//

import Foundation

class MusicModel: ObservableObject {
    /// The shared instance of this MusicModel class
    static let shared = MusicModel()
    // AppleScriptObjC object for communicating with iTunes
    var iTunesBridge: iTunesBridge
    
    @Published var trackInfo = Track()
    @Published var soundVolume: Double = 0
    
    var playerState: PlayerState {
        return PlayerState(rawValue: iTunesBridge._playerState as? Int ?? 0)!
    }
    
    var isRunning: Bool {
        return iTunesBridge._isRunning.boolValue
        
    }
    
    init() {
        // AppleScriptObjC setup
        Bundle.main.loadAppleScriptObjectiveCScripts()
        // create an instance of iTunesBridge script object for Swift code to use
        let iTunesBridgeClass: AnyClass = NSClassFromString("iTunesBridge")!
        self.iTunesBridge = iTunesBridgeClass.alloc() as! iTunesBridge
    }
    
    @MainActor func parseTrack() {
        trackInfo = Track(dictionary: iTunesBridge.trackInfo! as NSDictionary)
    }
    
    @MainActor func toggleLoved() {
        iTunesBridge.loved = [
            trackInfo.name as NSString,
            trackInfo.artist as NSString,
            trackInfo.album as NSString,
            NSString(string: "\(trackInfo.trackNumber)")
        ]
        parseTrack()
    }
    
    var trackDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let formattedString = formatter.string(from: TimeInterval(truncating: iTunesBridge.trackDuration))!
        return formattedString
    }
}

struct Track {
    var artist: String = ""
    var album: String = ""
    var name: String = ""
    var loved: Bool = false
    var trackNumber: Int = 0
}

extension Track {
    init(dictionary: NSDictionary) {
        self.artist = dictionary.value(forKey: "trackArtist") as! String
        self.album = dictionary.value(forKey: "trackAlbum") as! String
        self.name = dictionary.value(forKey: "trackName") as! String
        self.loved = dictionary.value(forKey: "trackLoved") as! Bool
        self.trackNumber = dictionary.value(forKey: "trackNumber") as! Int
    }
}
