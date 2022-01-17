//
//  ContentView.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var musicModel: MusicModel
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Name")
                        .modifier(ViewModifierLeft())
                    Text(musicModel.trackInfo.name)
                        .modifier(ViewModifierRight())
                }
                HStack {
                    Text("Artist")
                        .modifier(ViewModifierLeft())
                    Text(musicModel.trackInfo.artist)
                        .modifier(ViewModifierRight())
                }
                HStack {
                    Text("Album")
                        .modifier(ViewModifierLeft())
                    Text(musicModel.trackInfo.album)
                        .modifier(ViewModifierRight())
                }
                HStack {
                    Text("Duration")
                        .modifier(ViewModifierLeft())
                    Text(musicModel.trackDuration)
                        .modifier(ViewModifierRight())
                }
                HStack {
                    Button(action: {
                        musicModel.toggleLoved()
                    }, label: {
                        Label(title: {
                            Text(musicModel.trackInfo.loved ? "Unlove this song" : "Love this song")
                        }, icon: {
                            Image(systemName: musicModel.trackInfo.loved ? "heart.fill" : "heart")
                        })
                    })
                        .padding(.top)
                }
            }
            .padding()
            Slider(value: $musicModel.soundVolume, in: 0...100,
                   onEditingChanged: { _ in
                musicModel.musicBridge.soundVolume = NSNumber(value: musicModel.soundVolume)
            })
                .frame(width: 200)
            HStack {
                Button(action: {
                    musicModel.musicBridge.gotoPreviousTrack()
                }, label: {
                    Image(systemName: "backward.fill")
                })
                Button(action: {
                    musicModel.musicBridge.playPause()
                }, label: {
                    Image(systemName: musicModel.playerState == .playing ? "pause.fill" : "play.fill")
                })
                    .frame(width: 40)
                Button(action: {
                    musicModel.musicBridge.gotoNextTrack()
                }, label: {
                    Image(systemName: "forward.fill")
                })
            }
            .padding()
        }
        .frame(width: 400)
        .task {
            /// Update UI only if Music is already running
            if musicModel.isRunning {
                musicModel.parseTrack()
            }
            musicModel.soundVolume = musicModel.musicBridge.soundVolume.doubleValue
        }
    }
}

extension ContentView {
    /// View modifier for Left column
    struct ViewModifierLeft: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .frame(width: 100, alignment: .trailing)
        }
    }
    /// View modifier for Right column
    struct ViewModifierRight: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(width: 200, alignment: .leading)
        }
    }
}
