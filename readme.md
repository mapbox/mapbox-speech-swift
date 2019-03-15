# Mapbox Speech

Mapbox Speech connects your iOS application to the Mapbox Voice API. Take turn instructions from the [Mapbox Directions API](https://www.mapbox.com/api-documentation/#directions) and read them aloud naturally in multiple languages. This library is specifically designed to work with [MapboxDirections.swift](https://github.com/mapbox/MapboxDirections.swift/) as part of the [Mapbox Navigation SDK for iOS](https://github.com/mapbox/mapbox-navigation-ios/).

## Getting started

Specify the following dependency in your [Carthage](https://github.com/Carthage/Carthage) Cartfile:

```cartfile
github "mapbox/mapbox-speech-swift" ~> 0.1
```

Or in your [CocoaPods](http://cocoapods.org/) Podfile:

```podspec
pod 'MapboxSpeech', '~> 0.1.0'
```

Then `import MapboxSpeech` or `@import MapboxSpeech;`.

## Usage

You’ll need a [Mapbox access token](https://www.mapbox.com/developers/api/#access-tokens) in order to use the API. If you’re already using the [Mapbox Maps SDK for iOS](https://www.mapbox.com/ios-sdk/) or [macOS SDK](https://mapbox.github.io/mapbox-gl-native/macos/), Mapbox Speech automatically recognizes your access token, as long as you’ve placed it in the `MGLMapboxAccessToken` key of your application’s Info.plist file.

The examples below are each provided in Swift (denoted with `main.swift`) and Objective-C (`main.m`).

### Basics

The main speech synthesis class is SpeechSynthesizer (in Swift) or MBSpeechSynthesizer (in Objective-C). Create a speech synthesizer object using your access token:

```swift
// main.swift
import MapboxSpeech

let speechSynthesizer = SpeechSynthesizer(accessToken: "<#your access token#>")
```

```objc
// main.m
@import MapboxSpeech;

MBSpeechSynthesizer *speechSynthesizer = [[MBSpeechSynthesizer alloc] initWithAccessToken:@"<#your access token#>"];
```

Alternatively, you can place your access token in the `MGLMapboxAccessToken` key of your application’s Info.plist file, then use the shared speech synthesizer object:

```swift
// main.swift
let speechSynthesizer = SpeechSynthesizer.shared
```

```objc
// main.m
MBSpeechSynthesizer *speechSynthesizer = [MBSpeechSynthesizer sharedSpeechSynthesizer];
```

With the directions object in hand, construct a SpeechOptions or MBSpeechOptions object and pass it into the `SpeechSynthesizer.audioData(with:completionHandler:)` method.

```swift
// main.swift

let options = SpeechOptions(text: "hello, my name is Bobby")
speechSynthesizer.audioData(with: options) { (data: Data?, error: NSError?) in
    guard error == nil else {
        print("Error calculating directions: \(error!)")
        return
    }
    
    // Do something with the audio!
}
```

```objc
// main.m

MBSpeechOptions *options = [[MBSpeechOptions alloc] initWithText: "hello, my name is Bobby"];
[speechSynthesizer audioDataWithOptions:options completionHandler:^(NSData * _Nullable data,
                                                                    NSError * _Nullable error) {
    if (error) {
        NSLog(@"Error synthesizing speech: %@", error);
        return;
    }
    
    // Do something with the audio!
}];
```
