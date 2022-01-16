//
//  AppDelegate.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let musicModel: MusicModel = .shared

    @MainActor func applicationDidFinishLaunching(_ aNotification: Notification) {
        // iTunes emits track change notifications; very handy for UI refreshes
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(AppDelegate.updateTrackInfo),
                         name: NSNotification.Name(rawValue: "com.apple.Music.playerInfo"), object: nil)
        // update UI only if iTunes is already running, otherwise wait until user performs an action
        if self.musicModel.isRunning { self.updateTrackInfo() }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
//        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    //
    
    @MainActor @objc func updateTrackInfo() {
        if (self.musicModel.iTunesBridge.trackInfo) != nil { // nil indicates error, e.g. current track not available
            musicModel.parseTrack()
        }
    }
}
