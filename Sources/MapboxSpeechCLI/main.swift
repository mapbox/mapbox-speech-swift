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

let url = speech.url(forSynthesizing: options)
print("URL: \(url)")
let data = try! Data(contentsOf: url)
print("Data: \(data)")
let player = try! AVAudioPlayer(data: data)
player.play()
RunLoop.main.run(until: Date().addingTimeInterval(player.duration))

