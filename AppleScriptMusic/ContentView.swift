//
//  ContentView.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var musicModel: MusicModel
    @State private var hoverRating: Int = 0
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
                Divider()
                HStack {
                    Text("Rating")
                        .modifier(ViewModifierLeft())
                    ratings
                        .modifier(ViewModifierRight())
                }
                .padding(.top)
                Text(musicModel.trackInfo.trackRating == 5 ? "If you lower the rating, the song will be unloved" : "If you rate the song 5 stars, it will be loved as well")
                    .font(.caption)
                    .padding(.top, 1)
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
                Text(musicModel.trackInfo.loved ? "If you unlove the song, the rating will be removed" : "If you love the song, the rating will be set to 5 stars")
                    .font(.caption)
            }
            .padding()
            Divider()
                .padding()
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $musicModel.soundVolume, in: 0...100,
                       onEditingChanged: { _ in
                    musicModel.musicBridge.soundVolume = NSNumber(value: musicModel.soundVolume)
                })
                Image(systemName: "speaker.wave.3.fill")
            }
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
    /// Ratings
    var ratings: some View {
        HStack {
            ForEach(1..<6, id: \.self) { number in
                Image(systemName: "star.fill")
                    .foregroundColor(number > musicModel.trackInfo.trackRating ? Color.secondary : Color.yellow)
                    .onHover { hover in
                        hoverRating = hover ? number : 0
                    }
                    .scaleEffect(hoverRating == number ? 2 : 1)
                    .onTapGesture {
                        if number != musicModel.trackInfo.trackRating {
                            musicModel.setRating(rating: number)
                        }
                    }
                Divider()
                    .opacity(0)
            }
        }
        .animation(.easeInOut(duration: 0.1), value: hoverRating)
    }
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
