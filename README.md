# Mood2Movie Swift

SwiftUI port scaffold for the original `mood-2-movie` project.

## What is here

- `Mood2MovieSwift` executable package
- SwiftUI home, results, settings, and saved-movies screens
- Local persistence for preferences and saved movies
- A local recommendation service that mirrors the original mood-selection flow

## What is still to do

- Replace the local demo recommendation service with real TMDB and Claude-backed APIs
- Add auth and cloud sync if we want the same shared-library behavior as the web app
- Generate a real Xcode app project if we want native app packaging instead of a Swift package shell

## Notes

The current workspace only has the Command Line Tools Swift toolchain available, not `xcodebuild`, so this scaffold is optimized to be easy to open and finish in Xcode later.
