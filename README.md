# Mood2Movie Swift

SwiftUI port scaffold for the original `mood-2-movie` project.

## What is here

- `Mood2MovieSwift` executable package
- SwiftUI home, results, settings, and saved-movies screens
- Local persistence for preferences and saved movies
- A remote-first recommendation service that uses TMDB and Anthropic when API keys are present, with a local fallback for offline/demo mode

## What is still to do

- Replace the local demo recommendation service with real TMDB and Claude-backed APIs
- Add auth and cloud sync if we want the same shared-library behavior as the web app
- Generate a real Xcode app project if we want native app packaging instead of a Swift package shell

## API keys

Set these environment variables before launching in Xcode or from the terminal:

- `TMDB_API_KEY`
- `ANTHROPIC_API_KEY`
- `ANTHROPIC_MODEL` optional, defaults to `claude-3-5-haiku-latest`

## Notes

The current workspace only has the Command Line Tools Swift toolchain available, not `xcodebuild`, so this scaffold is optimized to be easy to open and finish in Xcode later.
