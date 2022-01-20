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
        dnc.addObserver(self, selector: #selector(AppDelegate.updateState),
                         name: NSNotification.Name(rawValue: "com.apple.Music.playerInfo"), object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        /// Nothing to do here
    }
    
    /// Update the state of this application when Music sends an update
    @objc func updateState(_ aNotification: Notification) {
        /// Check if there is a song or not
        if let message = aNotification.userInfo as NSDictionary?, message["Name"] as? String == nil {
            /// A notification without track name; Music stopped playing or is about to quit
            /// Give it moment to let Music setlle when it quits or else we get AppleScript errors
            sleep(1)
        }
        Task {
            await musicModel.getMusicState()
        }
    }
}
