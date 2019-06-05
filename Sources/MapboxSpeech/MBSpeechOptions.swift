import Foundation

@objc(MBTextType)
public enum TextType: UInt, CustomStringConvertible, Codable {
    
    case text
    
    case ssml
    
    public init?(description: String) {
        let type: TextType
        switch description {
        case "text":
            type = .text
        case "ssml":
            type = .ssml
        default:
            return nil
        }
        self.init(rawValue: type.rawValue)
    }
    
    public var description: String {
        switch self {
        case .text:
            return "text"
        case .ssml:
            return "ssml"
        }
    }
}

@objc(MBAudioFormat)
public enum AudioFormat: UInt, CustomStringConvertible, Codable {

    case mp3
    
    public init?(description: String) {
        let format: AudioFormat
        switch description {
        case "mp3":
            format = .mp3
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .mp3:
            return "mp3"
        }
    }
}

@objc(MBSpeechGender)
public enum SpeechGender: UInt, CustomStringConvertible, Codable {
    
    case female
    
    case male
    
    case neuter
    
    public init?(description: String) {
        let gender: SpeechGender
        switch description {
        case "female":
            gender = .female
        case "male":
            gender = .male
        default:
            gender = .neuter
        }
        self.init(rawValue: gender.rawValue)
    }
    
    public var description: String {
        switch self {
        case .female:
            return "female"
        case .male:
            return "male"
        case .neuter:
            return "neuter"
        }
    }
}

@objc(MBSpeechOptions)
open class SpeechOptions: NSObject, Codable {
    
    @objc public init(text: String) {
        self.text = text
        self.textType = .text
    }
    
    @objc public init(ssml: String) {
        self.text = ssml
        self.textType = .ssml
    }
    
    /**
     `String` to create audiofile for. Can either be plain text or [`SSML`](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language).
     
     If `SSML` is provided, `TextType` must be `TextType.ssml`.
     */
    @objc open var text: String
    
    
    /**
     Type of text to synthesize.
     
     `SSML` text must be valid `SSML` for request to work.
     */
    @objc let textType: TextType
    
    
    /**
     Audio format for outputted audio file.
     */
    @objc open var outputFormat: AudioFormat = .mp3
    
    /**
     The locale in which the audio is spoken.
     
     By default, the user's system locale will be used to decide upon an appropriate voice.
     */
    @objc open var locale: Locale = Locale.autoupdatingCurrent
    
    /**
     Gender of voice speeking text.
     
     Note: not all languages have both genders.
     */
    @objc open var speechGender: SpeechGender = .neuter
    
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
            URLQueryItem(name: "language", value: locale.identifier),
            URLQueryItem(name: "outputFormat", value: String(describing: outputFormat))
        ]
        
        if speechGender != .neuter {
            params.append(URLQueryItem(name: "gender", value: String(describing: speechGender)))
        }
        
        return params
    }
}
