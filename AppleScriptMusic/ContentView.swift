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
                        .font(.headline)
                        .frame(width: 100, alignment: .trailing)
                    Text(musicModel.trackInfo.name)
                        .frame(width: 200, alignment: .leading)
                }
                HStack {
                    Text("Artist")
                        .font(.headline)
                        .frame(width: 100, alignment: .trailing)
                    Text(musicModel.trackInfo.artist)
                        .frame(width: 200, alignment: .leading)
                }
                HStack {
                    Text("Album")
                        .font(.headline)
                        .frame(width: 100, alignment: .trailing)
                    Text(musicModel.trackInfo.album)
                        .frame(width: 200, alignment: .leading)
                }
                HStack {
                    Text("Duration")
                        .font(.headline)
                        .frame(width: 100, alignment: .trailing)
                    Text(musicModel.trackDuration)
                        .frame(width: 200, alignment: .leading)
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
                musicModel.iTunesBridge.soundVolume = NSNumber(value: musicModel.soundVolume)
            })
                .frame(width: 200)
            HStack {
                Button(action: {
                    musicModel.iTunesBridge.gotoPreviousTrack()
                }, label: {
                    Image(systemName: "backward.fill")
                })
                Button(action: {
                    musicModel.iTunesBridge.playPause()
                }, label: {
                    Image(systemName: musicModel.playerState == .playing ? "pause.fill" : "play.fill")
                })
                    .frame(width: 40)
                Button(action: {
                    musicModel.iTunesBridge.gotoNextTrack()
                }, label: {
                    Image(systemName: "forward.fill")
                })
            }
            .padding()
        }
        .frame(width: 400)
        .task {
            musicModel.soundVolume = musicModel.iTunesBridge.soundVolume.doubleValue
        }
    }
}
