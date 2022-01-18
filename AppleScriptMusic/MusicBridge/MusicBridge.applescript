script MusicBridge
	
	property parent : class "NSObject"
	
	-- Check if Music is running
	to _isRunning()
		-- AppleScript will automatically launch apps before sending Apple events;
		-- if that is undesirable, check the app object's `running` property first
        return running of application id "com.apple.Music"
	end isRunning
	
	-- Get the current state of Music
	to _playerState() -- () -> NSNumber (PlayerState)
		tell application id "com.apple.Music"
			if running then
				set currentState to player state
				-- ASOC does not bridge AppleScript's 'type class' and 'constant' values
				set i to 1
				repeat with stateEnumRef in {stopped, playing, paused, fast forwarding, rewinding}
					if currentState is equal to contents of stateEnumRef then return i
					set i to i + 1
				end repeat
			end if
            -- 'unknown'
			return 0
		end tell
	end playerState
	
	-- Get info about the current playing track
	to trackInfo()
		tell application id "com.apple.Music"
			try
				return {trackName:name, trackArtist:artist, trackAlbum:album, trackLoved:loved, trackNumber:track number, trackRating: rating, trackRatingKind: rating kind} of current track
			on error number -1728 -- current track is not available
				return missing value -- nil
			end try
		end tell
	end trackInfo
	
    -- Get the duration of the current playing track
	to trackDuration()
		tell application id "com.apple.Music"
			return duration of current track
		end tell
	end trackDuration
	
	-- Get the volume of Music
	to soundVolume()
		tell application id "com.apple.Music"
			return sound volume -- ASOC will convert returned integer to NSNumber
		end tell
	end soundVolume
	
    -- Set the volume of Music
	to setSoundVolume_(newVolume)
		-- ASOC does not convert NSObject parameters to AS types automaticallyÉ
		tell application id "com.apple.Music"
			-- Éso be sure to coerce NSNumber to native integer before using it in Apple event
			set sound volume to newVolume as integer
		end tell
	end setSoundVolume:
	
	-- Play or pause Music
	to playPause()
		tell application id "com.apple.Music" to playpause
	end playPause
	
    -- Goto next track
	to gotoNextTrack()
		tell application id "com.apple.Music" to next track
	end gotoNextTrack
	
    -- Goto previous track
	to gotoPreviousTrack()
		tell application id "com.apple.Music" to previous track
	end gotoPreviousTrack

    -- Love or unlove a song
    --
    -- If you onlove a song, the rating will be reset
    --
    -- I'm not using 'current track' here on purpose
    -- because I want to make it more 'modulair' for future projects.
    to setLoved_(theTrack)
        set trk to getTrackFromLibrary_(theTrack)
        set status to "I love this song"
        tell application id "com.apple.Music"
            if loved of trk is true then
                set status to "I don't love this song anymore"
                set loved of trk to false
                -- If you unlove a song, the rating will be removed
                set rating of trk to 1
            else
                set loved of trk to true
                --- Loved songs get a 5 star rating
                set rating of trk to 100
            end if
        end tell
        display notification status with title (name of trk) sound name "Frog"
    end setLoved

    -- Rate a song
    --
    -- If a song is rated 5 starts it will be 'loved' as well
    --
    -- I'm not using 'current track' here on purpose
    -- because I want to make it more 'modulair' for future projects.
    to setRating_(theTrack)
        set trk to getTrackFromLibrary_(theTrack)
        -- The first 4 items of theTrack is the identification of the track
        set trackRating to item 5 of theTrack as integer * 20
        set status to "I rate this song " & (trackRating / 20 as integer) & " stars"
        tell application id "com.apple.Music"
            set rating of trk to trackRating
            --- Love this song if it has 5 stars, unlove it when it is less
            if trackRating is 100 then
                set loved of trk to true
            else
                set loved of trk to false
            end if
        end tell
        display notification status with title (name of trk) sound name "Frog"
    end setRating

    -- Get a track from the Music Library
    --
    -- Persistent ID between AppleScript and iTunesLibrary do not match
    -- so we have to search by name, artist, album and track number
    -- to make sure we get the correct track.
    to getTrackFromLibrary_(theTrack)
        set trackName to item 1 of theTrack as strings
        set trackArtist to item 2 of theTrack as strings
        set trackAlbum to item 3 of theTrack as strings
        set trackNumber to item 4 of theTrack as strings
        tell application id "com.apple.Music"
            set trk to (first track whose name is trackName and artist = trackArtist and album = trackAlbum and track number = trackNumber)
        end tell
        return trk
    end getTrack

end script
