# MapboxSpeech.swift

A module for using the Mapbox Speech API specifically tuned for the [Mapbox Navigation SDK](https://www.mapbox.com/navigation/).

## Getting started

Specify the following dependency in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "mapbox/MapboxSpeech.swift" ~> 0.1
```

Or in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxSpeech.swift', '~> 0.1'
```

Then `import MapboxSpeech` or `@import MapboxSpeech;`.

## Basic Usage

```swift
// main.swift
import MapboxSpeech

let voice = SpeechSynthesizer(accessToken: "Your Mapbox access token")
let options = SpeechOptions(text: "hello, my name is Bobby")

voice.audioData(with: options) { (data: Data?, error: NSError?) in
    // Do something with the audio!
}
```
