import XCTest
import OHHTTPStubs
@testable import MapboxSpeech

let BogusToken = "pk.foo-bar"

class MapboxVoicZTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testExample() {
        let expectation = self.expectation(description: "Fetching speech audio should return results")
        
        let queryParams: [String: String?] = [
            "textType": "text",
            "voiceId": "Joanna",
            "outputFormat": "mp3",
            "access_token": BogusToken,
            ]
        
        stub(condition: isHost("api.mapbox.com")
            && isPath("/voice/v1/speak/hello")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "hello", ofType: "mp3")
                return OHHTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: nil)
        }
        
        let voice = SpeechSynthesizer(accessToken: BogusToken	)
        let options = SpeechOptions(text: "hello")
        options.textType = .text
        options.voiceId = .joanna
        options.outputFormat = .mp3
        
        var audio: Data?
        let task = voice.audioData(with: options) { (data: Data?, error: NSError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            audio = data!
            expectation.fulfill()
        }
        XCTAssertNotNil(task)
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
        
        XCTAssertNotNil(audio)
    }
}
