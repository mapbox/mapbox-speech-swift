import Foundation

@objc(MBTextType)
public enum TextType: UInt, CustomStringConvertible {
    
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
public enum AudioFormat: UInt, CustomStringConvertible {

    case mp3
    
    case oggVorbis
    
    case pcm
    
    public init?(description: String) {
        let format: AudioFormat
        switch description {
        case "mp3":
            format = .mp3
        case "ogg_vorbis":
            format = .oggVorbis
        case "pcm":
            format = .pcm
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .mp3:
            return "mp3"
        case .oggVorbis:
            return "ogg_vorbis"
        case .pcm:
            return "pcm"
        }
    }
}

@objc(MBSpeechGender)
public enum SpeechGender: UInt, CustomStringConvertible {
    
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
open class SpeechOptions: NSObject, NSSecureCoding {
    
    @objc public init(text: String) {
        self.text = text
        self.textType = .text
    }
    
    @objc public init(ssml: String) {
        self.text = ssml
        self.textType = .ssml
    }
    
    public required init?(coder decoder: NSCoder) {
        text = decoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "text") as? String ?? ""
        
        guard let textType = TextType(description: decoder.decodeObject(of: NSString.self, forKey: "textType") as String? ?? "") else {
            return nil
        }
        self.textType = textType
        
        guard let outputFormat = AudioFormat(description: decoder.decodeObject(of: NSString.self, forKey: "outputFormat") as String? ?? "") else {
            return nil
        }
        self.outputFormat = outputFormat
        
        if let locale = decoder.decodeObject(of: NSLocale.self, forKey: "locale") as Locale? {
            self.locale = locale
        }
        
        guard let speechGender = SpeechGender(description: decoder.decodeObject(of: NSString.self, forKey: "speechGender") as String? ?? "") else {
            return nil
        }
        self.speechGender = speechGender
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(textType, forKey: "textType")
        coder.encode(locale, forKey: "locale")
        coder.encode(outputFormat, forKey: "outputFormat")
        coder.encode(speechGender, forKey: "speechGender")
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
        let disallowedCharacters = (CharacterSet(charactersIn: "\\!*'();:@&=+$,/<>?%#[]\" ").inverted)
        return "voice/v1/speak/\(text.addingPercentEncoding(withAllowedCharacters: disallowedCharacters)!)"
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
