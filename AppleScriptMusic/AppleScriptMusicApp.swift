//
//  AppleScriptMusicApp.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI

/// The Main Application
@main
struct AppleScriptMusicApp: App {
    /// The MusicModel
    @StateObject var musicModel: MusicModel = .shared
    /// App delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// Toggle for notfications
    @AppStorage("showNotifications") var showNotifications = false
    /// The Scene
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(musicModel)
                .navigationTitle("Music Remote")
                .navigationSubtitle(musicModel.musicState.message)
                /// An empty toolbar so above will be shown below each other
                .toolbar {
                    ToolbarItem {
                        Toggle(isOn: $showNotifications) {
                            Image(systemName: showNotifications ? "bell.fill" : "bell")
                        }
                        .help(showNotifications ? "You get notifications" : "You get no notifications")
                    }
                }
        }
    }
}
