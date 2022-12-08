import XCTest
import OHHTTPStubs
@testable import MapboxSpeech

let BogusToken = "pk.foo-bar"

class MapboxVoiceTests: XCTestCase {
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testExample() {
        let expectation = self.expectation(description: "Fetching speech audio should return results")
        
        let queryParams: [String: String?] = [
            "textType": "text",
            "language": "en_US",
            "outputFormat": "mp3",
            "gender": "female",
            "access_token": BogusToken,
        ]
        
        stub(condition: isHost("api.mapbox.com")
            && isPath("/voice/v1/speak/hello")
            && containsQueryParams(queryParams)) { _ in
                let path = Bundle(for: type(of: self)).path(forResource: "hello", ofType: "mp3")
                return HTTPStubsResponse(fileAtPath: path!, statusCode: 200, headers: nil)
        }
        
        let voice = SpeechSynthesizer(accessToken: BogusToken)
        let options = SpeechOptions(text: "hello")
        options.outputFormat = .mp3
        options.speechGender = .female
        options.locale = Locale(identifier: "en_US")
        
        var audio: Data?
        let task = voice.audioData(with: options) { (data: Data?, error: SpeechError?) in
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

    func testCorrectJson() {
        let incorrectJson = "{\"code\": \"Ok\", \"message\": \"voice instruction\"}"
        let headers = ["Content-Type": "application/json"]
        let expectation = self.expectation(description: "Fetching speech audio should return results")
        stub(condition: isHost("api.mapbox.com") && isPath("/voice/v1/speak/hello")) { _ in
            let data = incorrectJson.data(using: .utf8)!
            return HTTPStubsResponse(data: data, statusCode: 200, headers: headers)
        }

        let voice = SpeechSynthesizer(accessToken: BogusToken)
        let options = SpeechOptions(text: "hello")
        options.outputFormat = .mp3
        options.speechGender = .female
        options.locale = Locale(identifier: "en_US")

        let task = voice.audioData(with: options) { (data: Data?, error: SpeechError?) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        XCTAssertNotNil(task)

        waitForExpectations(timeout: 2)
    }

    func testErrorInJson() {
        let incorrectJson = "{}}"
        let headers = ["Content-Type": "application/json"]
        let expectation = self.expectation(description: "Fetching speech audio should return results")
        stub(condition: isHost("api.mapbox.com") && isPath("/voice/v1/speak/hello")) { _ in
            let data = incorrectJson.data(using: .utf8)!
            return HTTPStubsResponse(data: data, statusCode: 200, headers: headers)
        }

        let voice = SpeechSynthesizer(accessToken: BogusToken)
        let options = SpeechOptions(text: "hello")
        options.outputFormat = .mp3
        options.speechGender = .female
        options.locale = Locale(identifier: "en_US")

        let task = voice.audioData(with: options) { (data: Data?, error: SpeechError?) in
            XCTAssertNotNil(error)
            XCTAssertNil(data)
            expectation.fulfill()
        }
        XCTAssertNotNil(task)

        waitForExpectations(timeout: 2)
    }
    
    func testCoding() {
        let options = SpeechOptions(ssml:
            """
            <speak><amazon:effect name="drc"><prosody rate="1.08">TEXT</prosody></amazon:effect></speak>
            """
        )
        options.outputFormat = .mp3
        options.speechGender = .female
        
        let encoded = try! JSONEncoder().encode(options)
        let decodedOptions = try! JSONDecoder().decode(SpeechOptions.self, from: encoded)
        
        XCTAssert(options.outputFormat == decodedOptions.outputFormat)
        XCTAssert(options.speechGender == decodedOptions.speechGender)
        XCTAssert(options.textType == decodedOptions.textType)
        XCTAssert(options.text == decodedOptions.text)
    }
    
    // Test whether error is returned in case if SpeechSynthesizer.audioData(with:completionHandler:) was cancelled.
    func testDataTaskCancel() {
        let expectation = self.expectation(description: "Cancelled task should return error.")
        let voice = SpeechSynthesizer(accessToken: BogusToken)
        let options = SpeechOptions(text: "hello")
        let task = voice.audioData(with: options) { (data: Data?, error: SpeechError?) in
            if let error = error,
                case let .unknown(response: _, underlying: underlyingError, code: _, message: _) = error,
                let urlError = underlyingError as? URLError {
                                
                XCTAssertEqual(urlError.code, .cancelled)
                expectation.fulfill()
                
                return
            }
            
            XCTFail("Since task is cancelled error is expected.")
        }
        
        XCTAssertNotNil(task)
        
        // Cancel URLSessionDataTask right after creation.
        task.cancel()
        
        waitForExpectations(timeout: 2) { (error) in
            XCTAssertNil(error, "Error: \(error!)")
            XCTAssertEqual(task.state, .completed)
        }
    }

    func testDataTaskFailed() {
        let expectation = self.expectation(description: "Should return error.")
        let voice = SpeechSynthesizer(accessToken: BogusToken)
        let options = SpeechOptions(text: "hello")

        let description = "error description"
        let userInfo = [NSLocalizedFailureReasonErrorKey: description]
        let mockedError = NSError(domain: "error domain", code: 1, userInfo: userInfo)
        stub(condition: isHost("api.mapbox.com") && isPath("/voice/v1/speak/hello")) { _ in
            return HTTPStubsResponse(error: mockedError)
        }

        let task = voice.audioData(with: options) { (data: Data?, error: SpeechError?) in
            guard let error = error,
                  case .unknown(response: _, underlying: let underlyingError, code: _, message: _) = error,
                  let innerError = underlyingError as? NSError else {
                XCTFail("SpeechSynthesizing should fail if data task failed")
                return
            }

            XCTAssertNil(data)
            XCTAssertEqual(innerError.localizedDescription, mockedError.localizedDescription)
            expectation.fulfill()
        }

        XCTAssertNotNil(task)

        waitForExpectations(timeout: 2)
        XCTAssertEqual(task.state, .completed)
    }
}
