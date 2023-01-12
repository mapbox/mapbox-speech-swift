#!/usr/bin/swift

import Foundation
import MapboxSpeech
import AVFoundation

guard CommandLine.arguments.count >= 2 else {
    print("Nothing to say?")
    exit(0)
}

guard let token = ProcessInfo.processInfo.environment["MAPBOX_ACCESS_TOKEN"] else {
    print("MAPBOX_ACCESS_TOKEN not found")
    exit(0)
}

let text = CommandLine.arguments[1]
let options = SpeechOptions(text: text)
var speech = SpeechSynthesizer(accessToken: token)

if CommandLine.arguments.count > 2 {
    let language = CommandLine.arguments[2]
    options.locale = .init(identifier: language)
}

let url = speech.url(forSynthesizing: options)
print("URL: \(url)")

do {
    let data = try Data(contentsOf: url)
    print("Data: \(data)")

    let audioPlayer = try AVAudioPlayer(data: data)
    audioPlayer.play()

    RunLoop.main.run(until: Date().addingTimeInterval(audioPlayer.duration))
} catch {
    print("Error occured: \(error)")
}
