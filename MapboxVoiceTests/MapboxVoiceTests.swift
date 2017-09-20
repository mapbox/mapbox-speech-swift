import XCTest
@testable import MapboxVoice

class MapboxVoicZTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let voice = Voice(accessToken: "pk.foo", host: "api-voice-staging.tilestream.net")
        let options = VoiceOptions(text: "foo")
        options.textType = .text
        options.voiceId = .joanna
        options.outputFormat = .mp3
        
        _ = voice.speak(options) { (data: Data?, error: NSError?) in
            XCTAssertNil(error)
            
            XCTAssertNotNil(data)
        }.resume()
    }
}
