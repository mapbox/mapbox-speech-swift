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

@objc(MBVoiceId)
public enum VoiceId: UInt, CustomStringConvertible {
    
    case Joanna
    
    public init?(description: String) {
        let voice: VoiceId
        switch description {
        case "Joanna":
            voice = .Joanna
        default:
            return nil
        }
        self.init(rawValue: voice.rawValue)
    }
    
    public var description: String {
        switch self {
        case .Joanna:
            return "Joanna"
        }
    }
}

@objc(MBAudioFormat)
public enum AudioFormat: UInt, CustomStringConvertible {
    
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

/**
 A `MeasurementSystem` indicates the type of units used for formatted a voice instruction.
 */
@objc(MBMeasurementSystem)
public enum MeasurementSystem: UInt, CustomStringConvertible {
    
    /**
     Imperial units.
     */
    case imperial
    
    /**
     Metric system.
     */
    case metric
    
    public init?(description: String) {
        let format: MeasurementSystem
        switch description {
        case "imperial":
            format = .imperial
        case "metric":
            format = .metric
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .imperial:
            return "imperial"
        case .metric:
            return "metric"
        }
    }
}


@objc(MBVoiceOptions)
open class VoiceOptions: NSObject, NSSecureCoding {
    
    public init(text: String) {
        self.text = text
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
        
        guard let voiceId = VoiceId(description: decoder.decodeObject(of: NSString.self, forKey: "voiceId") as String? ?? "") else {
            return nil
        }
        self.voiceId = voiceId
    }
    
    open static var supportsSecureCoding = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(textType, forKey: "textType")
        coder.encode(voiceId, forKey: "voiceId")
        coder.encode(outputFormat, forKey: "outputFormat")
    }
    
    open var text: String
    
    open var textType: TextType = .text
    
    open var voiceId: VoiceId = .Joanna
    
    open var outputFormat: AudioFormat = .mp3
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        return "voice/v1/\(text)"
    }
    
    /**
     An array of URL parameters to include in the request URL.
     */
    internal var params: [URLQueryItem] {
        let params: [URLQueryItem] = [
            URLQueryItem(name: "TextType", value: String(describing: textType)),
            URLQueryItem(name: "VoiceId", value: String(describing: voiceId)),
            URLQueryItem(name: "OutputFormat", value: String(describing: outputFormat))
        ]
        
        return params
    }
}
