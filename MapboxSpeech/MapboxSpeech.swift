import Foundation

typealias JSONDictionary = [String: Any]

/// Indicates that an error occurred in MapboxSpeech.
public let MBSpeechErrorDomain = "MBSpeechErrorDomain"

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String

/// The user agent string for any HTTP requests performed directly within this library.
let userAgent: String = {
    var components: [String] = []
    
    if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        components.append("\(appName)/\(version)")
    }
    
    let libraryBundle: Bundle? = Bundle(for: SpeechSynthesizer.self)
    
    if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String, let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
        components.append("\(libraryName)/\(version)")
    }
    
    let system: String
    #if os(OSX)
        system = "macOS"
    #elseif os(iOS)
        system = "iOS"
    #elseif os(watchOS)
        system = "watchOS"
    #elseif os(tvOS)
        system = "tvOS"
    #elseif os(Linux)
        system = "Linux"
    #endif
    let systemVersion = ProcessInfo().operatingSystemVersion
    components.append("\(system)/\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)")
    
    let chip: String
    #if arch(x86_64)
        chip = "x86_64"
    #elseif arch(arm)
        chip = "arm"
    #elseif arch(arm64)
        chip = "arm64"
    #elseif arch(i386)
        chip = "i386"
    #endif
    components.append("(\(chip))")
    
    return components.joined(separator: " ")
}()

/**
 A `SpeechSynthesizer` object converts text into spoken audio. Unlike `AVSpeechSynthesizer`, a `SpeechSynthesizer` object produces audio by sending an HTTP request to the Mapbox Voice API, which produces more natural-sounding audio in various languages. With a speech synthesizer object, you can asynchronously generate audio data based on the `SpeechOptions` object you provide, or you can get the URL used to make this request.
 
 Use `AVAudioPlayer` to play the audio that a speech synthesizer object produces.
 */
@objc(MBSpeechSynthesizer)
open class SpeechSynthesizer: NSObject {
    
    public typealias CompletionHandler = (_ data: Data?, _ error: NSError?) -> Void
    
    // MARK: Creating a Speech Object
    
    /**
     The shared speech synthesizer object.
     
     To use this object, specify a Mapbox [access token](https://www.mapbox.com/help/define-access-token/) in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    @objc(sharedSpeechSynthesizer)
    public static let shared = SpeechSynthesizer(accessToken: nil)
    
    /// The API endpoint to request the audio from.
    @objc public private(set) var apiEndpoint: URL
    
    /// The Mapbox access token to associate the request with.
    @objc public let accessToken: String
    
    /**
     Initializes a newly created speech synthesizer object with an optional access token and host.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the speech synthesizer object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     - parameter host: An optional hostname to the server API. The Mapbox Voice API endpoint is used by default.
     */
    @objc public init(accessToken: String?, host: String?) {
        let accessToken = accessToken ?? defaultAccessToken
        assert(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://www.mapbox.com/studio/account/tokens/>. In Info.plist, set the MGLMapboxAccessToken key to your access token, or use the Speech(accessToken:host:) initializer.")
        
        self.accessToken = accessToken!
        
        var baseURLComponents = URLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = host ?? "api.mapbox.com"
        self.apiEndpoint = baseURLComponents.url!
    }
    
    /**
     Initializes a newly created speech synthesizer object with an optional access token.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the speech synthesizer object, it should be specified in the `MGLMapboxAccessToken` key in the main application bundle’s Info.plist.
     */
    @objc public convenience init(accessToken: String?) {
        self.init(accessToken: accessToken, host: nil)
    }
    
    // MARK: Getting Speech
    
    /**
     Begins asynchronously fetching the audio file.
     
     This method retrieves the audio asynchronously over a network connection. If a connection error or server error occurs, details about the error are passed into the given completion handler in lieu of the audio file.
     
     - parameter options: A `SpeechOptions` object specifying the requirements for the resulting audio file.
     - parameter completionHandler: The closure (block) to call with the resulting audio. This closure is executed on the application’s main thread.
     - returns: The data task used to perform the HTTP request. If, while waiting for the completion handler to execute, you no longer want the resulting audio, cancel this task.
     */
    @objc(audioDataWithOptions:completionHandler:)
    @discardableResult open func audioData(with options: SpeechOptions, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let url = self.url(forSynthesizing: options)
        let task = dataTask(with: url, completionHandler: { (data) in
            completionHandler(data, nil)
        }) { (error) in
            completionHandler(nil, error)
        }
        task.resume()
        return task
    }
    
    /**
     Returns a URL session task for the given URL that will run the given closures on completion or error.
     
     - parameter url: The URL to request.
     - parameter completionHandler: The closure to call with the parsed JSON response dictionary.
     - parameter errorHandler: The closure to call when there is an error.
     - returns: The data task for the URL.
     - postcondition: The caller must resume the returned task.
     */
    fileprivate func dataTask(with url: URL, completionHandler: @escaping (_ data: Data) -> Void, errorHandler: @escaping (_ error: NSError) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            // Parse error object
            var errorJSON: JSONDictionary = [:]
            if let data = data, response?.mimeType == "application/json" {
                do {
                    errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
                } catch {
                    assert(false, "Invalid data")
                }
            }
            
            let apiStatusCode = errorJSON["code"] as? String
            let apiMessage = errorJSON["message"] as? String
            guard data != nil && error == nil && ((apiStatusCode == nil && apiMessage == nil) || apiStatusCode == "Ok") else {
                let apiError = SpeechSynthesizer.informativeError(describing: errorJSON, response: response, underlyingError: error as NSError?)
                DispatchQueue.main.async {
                    errorHandler(apiError)
                }
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                completionHandler(data)
            }
        }
        task.resume()
        return task
    }
    
    /**
     The HTTP URL used to fetch audio from the API.
     */
    @objc(URLForSynthesizingSpeechWithOptions:)
    open func url(forSynthesizing options: SpeechOptions) -> URL {
        let params = options.params + [
            URLQueryItem(name: "access_token", value: accessToken),
        ]
        
        let unparameterizedURL = URL(string: options.path, relativeTo: apiEndpoint)!
        var components = URLComponents(url: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }
    
    /**
     Returns an error that supplements the given underlying error with additional information from the an HTTP response’s body or headers.
     */
    static func informativeError(describing json: JSONDictionary, response: URLResponse?, underlyingError error: NSError?) -> NSError {
        let apiStatusCode = json["code"] as? String
        var userInfo = error?.userInfo ?? [:]
        if let response = response as? HTTPURLResponse {
            var failureReason: String? = nil
            var recoverySuggestion: String? = nil
            switch (response.statusCode, apiStatusCode ?? "") {
            case (429, _):
                if let timeInterval = response.rateLimitInterval, let maximumCountOfRequests = response.rateLimit {
                    let intervalFormatter = DateComponentsFormatter()
                    intervalFormatter.unitsStyle = .full
                    let formattedInterval = intervalFormatter.string(from: timeInterval) ?? "\(timeInterval) seconds"
                    let formattedCount = NumberFormatter.localizedString(from: NSNumber(value: maximumCountOfRequests), number: .decimal)
                    failureReason = "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
                }
                if let rolloverTime = response.rateLimitResetTime {
                    let formattedDate = DateFormatter.localizedString(from: rolloverTime, dateStyle: .long, timeStyle: .long)
                    recoverySuggestion = "Wait until \(formattedDate) before retrying."
                }
            default:
                failureReason = json["message"] as? String
            }
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?? userInfo[NSLocalizedFailureReasonErrorKey] ?? HTTPURLResponse.localizedString(forStatusCode: error?.code ?? -1)
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion ?? userInfo[NSLocalizedRecoverySuggestionErrorKey]
        }
        if let error = error {
            userInfo[NSUnderlyingErrorKey] = error
        }
        return NSError(domain: error?.domain ?? MBSpeechErrorDomain, code: error?.code ?? -1, userInfo: userInfo)
    }
}

extension HTTPURLResponse {
    var rateLimit: UInt? {
        guard let limit = allHeaderFields["X-Rate-Limit-Limit"] as? String else {
            return nil
        }
        return UInt(limit)
    }
    
    var rateLimitInterval: TimeInterval? {
        guard let interval = allHeaderFields["X-Rate-Limit-Interval"] as? String else {
            return nil
        }
        return TimeInterval(interval)
    }
    
    var rateLimitResetTime: Date? {
        guard let resetTime = allHeaderFields["X-Rate-Limit-Reset"] as? String else {
            return nil
        }
        guard let resetTimeNumber = Double(resetTime) else {
            return nil
        }
        return Date(timeIntervalSince1970: resetTimeNumber)
    }
}
