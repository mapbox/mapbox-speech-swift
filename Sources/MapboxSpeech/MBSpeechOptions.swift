import Foundation

public enum TextType: String, Codable {
    case text
    case ssml
}

public enum AudioFormat: String, Codable {
    case mp3
}

public enum SpeechGender: String, Codable {
    case female
    case male
    case neuter
}

open class SpeechOptions: Codable {
    public init(text: String) {
        self.text = text
        textType = .text
    }
    
    public init(ssml: String) {
        self.text = ssml
        textType = .ssml
    }
    
    /**
     `String` to create audiofile for. Can either be plain text or [`SSML`](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language).
     
     If `SSML` is provided, `TextType` must be `TextType.ssml`.
     */
    open var text: String
    
    /**
     Type of text to synthesize.
     
     `SSML` text must be valid `SSML` for request to work.
     */
    let textType: TextType
    
    /**
     Audio format for outputted audio file.
     */
    open var outputFormat: AudioFormat = .mp3
    
    /**
     The locale in which the audio is spoken.
     
     By default, the user's system locale will be used to decide upon an appropriate voice.
     */
    open var locale: Locale = .autoupdatingCurrent
    
    /**
     Gender of voice speeking text.
     
     Note: not all languages have both genders.
     */
    open var speechGender: SpeechGender = .neuter
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        var characterSet = CharacterSet.urlPathAllowed
        characterSet.remove(charactersIn: "/")
        return "voice/v1/speak/\(text.addingPercentEncoding(withAllowedCharacters: characterSet)!)"
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "textType", value: String(describing: textType)),
            URLQueryItem(name: "language", value: locale.amazonIdentifier),
            URLQueryItem(name: "outputFormat", value: String(describing: outputFormat))
        ]
        
        if speechGender != .neuter {
            params.append(URLQueryItem(name: "gender", value: String(describing: speechGender)))
        }
        
        return params
    }
}

public extension Locale {
    
    /**
     `String` Returns the identifier of the locale identifier supported by Amazon Polly [`Supported Language`](https://docs.aws.amazon.com/polly/latest/dg/SupportedLanguage.html).
     
     While common language identifiers are two-letter `ISO 639-1` standard, three-letter `ISO 639-2` standard or even `RFC 4647` (known as BCP 47), `Amazon Polly` uses `ISO 639-3`
     W3C language identification which creates incompatibility with `Locale.current`.
     This computed property either return `Locale.identifier` or the supported version of the unknown code.
     List of currently unsupported codes :
     "ar-SA", "zh-CN", "zh-HK", "zh-Hans", "zh-Hant", "zh-TW"
     */
    var amazonIdentifier : String {
        let unsupported : Dictionary<String, String> = [
            "ar-SA" : "arb",
            "zh-CN" : "cmn-CN",
            "zh-HK" : "cmn-CN",
            "zh-Hans" : "cmn-CN" ,
            "zh-Hant" : "cmn-CN",
            "zh-TW" : "cmn-CN",
        ]
        if unsupported.keys.contains(self.identifier), let patchedIdentifier = unsupported[ self.identifier ] {
            return patchedIdentifier
        }
        return self.identifier
    }
}

