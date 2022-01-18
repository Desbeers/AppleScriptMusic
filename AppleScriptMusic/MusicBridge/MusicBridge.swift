//
//  MusicBridge.swift
//  AppleScriptMusic
//
//  Created by Nick Berendsen on 15/01/2022.
//

import Foundation

@objc(NSObject) protocol MusicBridge {
    
    /// Important: ASOC does not bridge C primitives, only Cocoa classes and objects,
    /// so Swift Bool/Int/Double values MUST be explicitly boxed/unboxed as NSNumber
    /// when passing to/from AppleScript.
    
    /// I dont know the 'inner working' of all this black magic, but found out that when 'setting' a var
    /// an AppleScript with the name 'setVar' is called.
    /// For example; if you 'get the sound volume, 'soundVolume' script will run, but when setting
    /// the value 'setSoundVolume will run. You can't call 'set' functions by yourself...
    
    /// Bool if Music is running
    var _isRunning: NSNumber { get }
    /// Emun with the current state of Music
    var _playerState: NSNumber { get }
    /// Info about current track playing in Music
    var trackInfo: [NSString: AnyObject]? { get }
    /// Duration of the current track
    var trackDuration: NSNumber { get }
    /// The volume level of Music
    var soundVolume: NSNumber { get set }
    /// Play/pause Music
    func playPause()
    /// Play previous track
    func gotoPreviousTrack()
    /// Play next track
    func gotoNextTrack()
    /// Love or unlove a song
    var loved: [NSString] { get set }
    /// Rate a song
    var rating: [NSString] { get set }
}

/// Music' 'player state' property
enum PlayerState: Int {
    case unknown
    case stopped
    case playing
    case paused
    case fastForwarding
    case rewinding
}
