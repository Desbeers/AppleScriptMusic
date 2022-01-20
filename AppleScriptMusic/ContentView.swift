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
            HStack {
                musicModel.trackInfo.cover
                    .resizable()
                    .cornerRadius(2)
                    .frame(width: 140, height: 140)
                    .padding(.leading)
                    .opacity(musicModel.trackInfo.title.isEmpty ? 0.1 : 1)
                VStack {
                    HStack {
                        Text("Title")
                            .modifier(ViewModifierLeft())
                        Text(musicModel.trackInfo.title)
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
                        Text(musicModel.trackInfo.duration)
                            .modifier(ViewModifierRight())
                    }
                }
            }
            .padding(.top)
            Divider()
                .padding(.horizontal)
            HStack {
                Text("Rating")
                    .modifier(ViewModifierLeft())
                ratings
                    .modifier(ViewModifierRight())
            }
            .padding(.top)
            Text(musicModel.trackInfo.rating == 5 ? "If you lower the rating, the song will be unloved" : "If you rate the song 5 stars, it will be loved as well")
                .font(.caption)
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
            }
            Text(musicModel.trackInfo.loved ? "If you unlove the song, the rating will be removed" : "If you love the song, the rating will be set to 5 stars")
                .font(.caption)
            Divider()
                .padding()
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $musicModel.musicState.volume, in: 0...100,
                       onEditingChanged: { _ in
                    musicModel.musicBridge.soundVolume = NSNumber(value: musicModel.musicState.volume)
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
                    Image(systemName: musicModel.musicState.status == .playing ? "pause.fill" : "play.fill")
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
        .disabled(!musicModel.musicState.running)
        .opacity(musicModel.musicState.running ? 1 : 0.5)
        .frame(width: 450, height: 400)
        .task {
            await musicModel.getMusicState()
        }
    }
}

extension ContentView {
    /// Ratings
    var ratings: some View {
        HStack {
            ForEach(1..<6, id: \.self) { number in
                Divider()
                    .opacity(0)
                Image(systemName: "star.fill")
                    .foregroundColor(number > musicModel.trackInfo.rating ? Color.secondary : Color.yellow)
                    .onHover { hover in
                        hoverRating = hover ? number : 0
                    }
                    .scaleEffect(hoverRating == number ? 2 : 1)
                    .onTapGesture {
                        /// Remove the star is it is the current selection
                        let rating = number == musicModel.trackInfo.rating ? number - 1 : number
                        musicModel.setRating(rating: rating)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.1), value: hoverRating)
    }
    /// View modifier for Left column
    struct ViewModifierLeft: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.headline)
                .frame(width: 60, alignment: .trailing)
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
