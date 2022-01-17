//
//  AppDelegate.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    /// The shared MusicModel
    let musicModel: MusicModel = .shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /// Music emits track change notifications; very handy for UI refreshes
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(AppDelegate.updateTrackInfo),
                         name: NSNotification.Name(rawValue: "com.apple.Music.playerInfo"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        /// Nothing to do here
    }
    
    /// Update the track information when Music sends an update
    @objc func updateTrackInfo(_ aNotification: Notification) {
        /// nil indicates error, e.g. current track not available
        if (musicModel.musicBridge.trackInfo) != nil {
            Task { @MainActor in
                musicModel.parseTrack()
            }
        }
    }
}
