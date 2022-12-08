import Foundation

typealias JSONDictionary = [String: Any]

/// The Mapbox access token specified in the main application bundle’s Info.plist.
let defaultAccessToken =
    Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String ??
    Bundle.main.object(forInfoDictionaryKey: "MGLMapboxAccessToken") as? String

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
    
    // `ProcessInfo().operatingSystemVersionString` can replace this when swift-corelibs-foundaton is next released:
    // https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/ProcessInfo.swift#L104-L202
    let system: String
    #if os(macOS)
        system = "macOS"
    #elseif os(iOS)
        system = "iOS"
    #elseif os(watchOS)
        system = "watchOS"
    #elseif os(tvOS)
        system = "tvOS"
    #elseif os(Linux)
        system = "Linux"
    #else
        system = "unknown"
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
    #else
        // Maybe fall back on `uname(2).machine`?
        chip = "unrecognized"
    #endif
    
    var simulator: String? = nil
    #if targetEnvironment(simulator)
    simulator = "Simulator"
    #endif
    
    let otherComponents = [
        chip,
        simulator
    ].compactMap({ $0 })

    components.append("(\(otherComponents.joined(separator: "; ")))")
    
    return components.joined(separator: " ")
}()

/**
 A `SpeechSynthesizer` object converts text into spoken audio. Unlike `AVSpeechSynthesizer`, a `SpeechSynthesizer` object produces audio by sending an HTTP request to the Mapbox Voice API, which produces more natural-sounding audio in various languages. With a speech synthesizer object, you can asynchronously generate audio data based on the `SpeechOptions` object you provide, or you can get the URL used to make this request.
 
 Use `AVAudioPlayer` to play the audio that a speech synthesizer object produces.
 */
open class SpeechSynthesizer {
    public typealias CompletionHandler = (_ data: Data?, _ error: SpeechError?) -> Void
    
    // MARK: Creating a Speech Object
    
    /**
     The shared speech synthesizer object.
     
     To use this object, specify a Mapbox [access token](https://www.mapbox.com/help/define-access-token/) in the `MBXAccessToken` key in the main application bundle’s Info.plist.
     */
    public static let shared = SpeechSynthesizer(accessToken: nil)
    
    /// The API endpoint to request the audio from.
    public private(set) var apiEndpoint: URL
    
    /// The Mapbox access token to associate the request with.
    public let accessToken: String

    private var skuToken: String? {
        guard let mbx: AnyClass = NSClassFromString("MBXAccounts"),
              mbx.responds(to: Selector(("serviceSkuToken"))),
              let serviceSkuToken = mbx.value(forKeyPath: "serviceSkuToken") as? String
        else { return nil }
        if mbx.responds(to: Selector(("serviceAccessToken"))) {
            guard let serviceAccessToken = mbx.value(forKeyPath: "serviceAccessToken") as? String,
                  serviceAccessToken == accessToken
            else { return nil }
            
            return serviceSkuToken
        }

        return serviceSkuToken
    }
    
    /**
     Initializes a newly created speech synthesizer object with an optional access token and host.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the speech synthesizer object, it should be specified in the `MBXAccessToken` key in the main application bundle’s Info.plist.
     - parameter host: An optional hostname to the server API. The Mapbox Voice API endpoint is used by default.
     */
    public init(accessToken: String?, host: String?) {
        let accessToken = accessToken ?? defaultAccessToken
        assert(accessToken != nil && !accessToken!.isEmpty, "A Mapbox access token is required. Go to <https://www.mapbox.com/studio/account/tokens/>. In Info.plist, set the MBXAccessToken key to your access token, or use the Speech(accessToken:host:) initializer.")
        
        self.accessToken = accessToken!
        
        var baseURLComponents = URLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = host ?? "api.mapbox.com"
        self.apiEndpoint = baseURLComponents.url!
    }
    
    /**
     Initializes a newly created speech synthesizer object with an optional access token.
     
     - parameter accessToken: A Mapbox [access token](https://www.mapbox.com/help/define-access-token/). If an access token is not specified when initializing the speech synthesizer object, it should be specified in the `MBXAccessToken` key in the main application bundle’s Info.plist.
     */
    public convenience init(accessToken: String?) {
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
    @discardableResult open func audioData(with options: SpeechOptions, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let url = self.url(forSynthesizing: options)
        let task = dataTask(with: url, completionHandler: { (data) in
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                completionHandler(nil, error)
            }
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
    fileprivate func dataTask(with url: URL, completionHandler: @escaping (_ data: Data) -> Void, errorHandler: @escaping (_ error: SpeechError) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (possibleData, possibleResponse, possibleError) in
            if let error = possibleError {
                errorHandler(.unknown(response: possibleResponse, underlying: error, code: nil, message: nil))
                return
            }
            
            guard let data = possibleData else {
                errorHandler(.noData)
                return
            }
            
            guard let response = possibleResponse else {
                errorHandler(.invalidResponse)
                return
            }
            
            // Parse error object
            if response.mimeType == "application/json" {
                var errorJSON: JSONDictionary = [:]
                do {
                    errorJSON = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
                } catch {
                    errorHandler(SpeechSynthesizer.informativeError(code: nil, message: nil, response: response, underlyingError: error))
                    return
                }
                
                let apiStatusCode = errorJSON["code"] as? String
                let apiMessage = errorJSON["message"] as? String
                guard (apiStatusCode == nil && apiMessage == nil) || apiStatusCode == "Ok" else {
                    let apiError = SpeechSynthesizer.informativeError(code: apiStatusCode, message: apiMessage, response: response, underlyingError: possibleError)
                    errorHandler(apiError)
                    return
                }
            }

            completionHandler(data)
        }
        task.resume()
        return task
    }
    
    /**
     The HTTP URL used to fetch audio from the API.
     */
    open func url(forSynthesizing options: SpeechOptions) -> URL {
        var params = options.params
        
        params += [URLQueryItem(name: "access_token", value: accessToken)]
        
        if let skuToken = skuToken {
            params += [URLQueryItem(name: "sku", value: skuToken)]
        }
        
        let unparameterizedURL = URL(string: options.path, relativeTo: apiEndpoint)!
        var components = URLComponents(url: unparameterizedURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }
    
    /**
     Returns an error that supplements the given underlying error with additional information from the an HTTP response’s body or headers.
     */
    static func informativeError(code: String?, message: String?, response: URLResponse?, underlyingError error: Error?) -> SpeechError {
        if let response = response as? HTTPURLResponse {
            switch (response.statusCode, code ?? "") {
            case (429, _):
                return .rateLimited(rateLimitInterval: response.rateLimitInterval, rateLimit: response.rateLimit, resetTime: response.rateLimitResetTime)
            default:
                return .unknown(response: response, underlying: error, code: code, message: message)
            }
        }
        return .unknown(response: response, underlying: error, code: code, message: message)
    }
}

public enum SpeechError: LocalizedError {
    case noData
    case invalidResponse
    case rateLimited(rateLimitInterval: TimeInterval?, rateLimit: UInt?, resetTime: Date?)
    case unknown(response: URLResponse?, underlying: Error?, code: String?, message: String?)
    
    public var failureReason: String? {
        switch self {
        case .noData:
            return "The server returned an empty response."
        case .invalidResponse:
            return "The server returned a response that isn’t correctly formatted."
        case let .rateLimited(rateLimitInterval: interval, rateLimit: limit, _):
            let intervalFormatter = DateComponentsFormatter()
            intervalFormatter.unitsStyle = .full
            guard let interval = interval, let limit = limit else {
                return "Too many requests."
            }
            let formattedInterval = intervalFormatter.string(from: interval) ?? "\(interval) seconds"
            let formattedCount = NumberFormatter.localizedString(from: NSNumber(value: limit), number: .decimal)
            return "More than \(formattedCount) requests have been made with this access token within a period of \(formattedInterval)."
        case let .unknown(_, underlying: error, _, message):
            return message
                ?? (error as NSError?)?.userInfo[NSLocalizedFailureReasonErrorKey] as? String
                ?? HTTPURLResponse.localizedString(forStatusCode: (error as NSError?)?.code ?? -1)
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .noData:
            return nil
        case .invalidResponse:
            return nil
        case let .rateLimited(rateLimitInterval: _, rateLimit: _, resetTime: rolloverTime):
            guard let rolloverTime = rolloverTime else {
                return nil
            }
            let formattedDate: String = DateFormatter.localizedString(from: rolloverTime, dateStyle: .long, timeStyle: .long)
            return "Wait until \(formattedDate) before retrying."
        case let .unknown(_, underlying: error, _, _):
            return (error as NSError?)?.userInfo[NSLocalizedRecoverySuggestionErrorKey] as? String
        }
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
