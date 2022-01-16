//
//  AppleScriptMusicApp.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI
import AppleScriptObjC

@main
struct AppleScriptMusicApp: App {
    /// The MusicModel
    @StateObject var musicModel: MusicModel = .shared
    /// App delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// The Scene
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(musicModel)
                .navigationTitle("SwiftUI Music Remote with AppleScript")
                .navigationSubtitle("Proof of concept")
                .toolbar {
                    ToolbarItem {
                        Spacer()
                    }
                }
        }
    }
}
