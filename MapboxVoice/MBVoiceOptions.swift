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
    
    /**
     Female voice for `Locale` `en-US.`
     */
    case joanna
    
    /**
     Female voice for `Locale` `ja-JP.`
     */
    case mizuki
    
    /**
     Female voice for `Locale` `tr-TR.`
     */
    case filiz
    
    /**
     Female voice for `Locale` `sv-SE.`
     */
    case astrid
    
    /**
     Female voice for `Locale` `ru-RU.`
     */
    case tatyana
    
    /**
     Male voice for `Locale` `ru-RU.`
     */
    case maxim
    
    /**
     Female voice for `Locale` `ro-RO.`
     */
    case carmen
    
    /**
     Female voice for `Locale` `pt-PT.`
     */
    case ines
    
    /**
     Male voice for `Locale` `pt-PT.`
     */
    case cristiano
    
    /**
     Female voice for `Locale` `pt-BR.`
     */
    case vitoria
    
    /**
     Male voice for `Locale` `pt-BR.`
     */
    case ricardo
    
    /**
     Female voice for `Locale` `pl-PL.`
     */
    case maja
    
    /**
     Male voice for `Locale` `pl-PL.`
     */
    case jan
    
    /**
     Female voice for `Locale` `pl-PL.`
     */
    case ewa
    
    /**
     Male voice for `Locale` `nl-NL.`
     */
    case ruben
    
    /**
     Female voice for `Locale` `nl-NL.`
     */
    case lotte
    
    /**
     Female voice for `Locale` `nb-NO.`
     */
    case liv
    
    /**
     Male voice for `Locale` `it-IT.`
     */
    case giorgio
    
    /**
     Female voice for `Locale` `it-IT.`
     */
    case carla
    
    /**
     Male voice for `Locale` `is-IS.`
     */
    case karl
    
    /**
     Female voice for `Locale` `is-IS.`
     */
    case dora
    
    /**
     Male voice for `Locale` `fr-FR.`
     */
    case mathieu
    
    /**
     Female voice for `Locale` `fr-FR.`
     */
    case celine
    
    /**
     Female voice for `Locale` `fr-CA.`
     */
    case chantal
    
    /**
     Female voice for `Locale` `es-US.`
     */
    case penelope
    
    /**
     Male voice for `Locale` `es-US.`
     */
    case miguel
    
    /**
     Male voice for `Locale` `es-ES.`
     */
    case enrique
    
    /**
     Female voice for `Locale` `es-ES.`
     */
    case conchita
    
    /**
     Male voice for `Locale` `en-GB-WLS.`
     */
    case geraint
    
    /**
     Female voice for `Locale` `en-US.`
     */
    case salli
    
    /**
     Female voice for `Locale` `en-US.`
     */
    case kimberly
    
    /**
     Female voice for `Locale` `en-US.`
     */
    case kendra
    
    /**
     Male voice for `Locale` `en-US.`
     */
    case justin
    
    /**
     Male voice for `Locale` `en-US.`
     */
    case joey
    
    /**
     Female voice for `Locale` `en-US.`
     */
    case ivy
    
    /**
     Female voice for `Locale` `en-IN.`
     */
    case raveena
    
    /**
     Female voice for `Locale` `en-GB.`
     */
    case emma
    
    /**
     Male voice for `Locale` `en-GB.`
     */
    case brian
    
    /**
     Female voice for `Locale` `en-GB.`
     */
    case amy
    
    /**
     Male voice for `Locale` `en-AU.`
     */
    case russell
    
    /**
     Female voice for `Locale` `en-AU.`
     */
    case nicole
    
    /**
     Female voice for `Locale` `de-DE.`
     */
    case vicki
    
    /**
     Female voice for `Locale` `de-DE.`
     */
    case marlene
    
    /**
     Male voice for `Locale` `de-DE.`
     */
    case hans
    
    /**
     Female voice for `Locale` `da-DK.`
     */
    case naja
    
    /**
     Male voice for `Locale` `da-DK.`
     */
    case mads
    
    /**
     Female voice for `Locale` `cy-GB.`
     */
    case gwyneth
    
    /**
     Male voice for `Locale` `pl-PL.`
     */
    case jacek
    
    public init?(description: String) {
        let voice: VoiceId
        switch description {
        case "Joanna":
            voice = .joanna
        case "Mizuki":
            voice = .mizuki
        case "Filiz":
            voice = .filiz
        case "Astrid":
            voice = .astrid
        case "Tatyana":
            voice = .tatyana
        case "Maxim":
            voice = .maxim
        case "Carmen":
            voice = .carmen
        case "Ines":
            voice = .ines
        case "Cristiano":
            voice = .cristiano
        case "Vitoria":
            voice = .vitoria
        case "Ricardo":
            voice = .ricardo
        case "Maja":
            voice = .maja
        case "Jan":
            voice = .jan
        case "Ewa":
            voice = .ewa
        case "Ruben":
            voice = .ruben
        case "Lotte":
            voice = .lotte
        case "Liv":
            voice = .liv
        case "Giorgio":
            voice = .giorgio
        case "Carla":
            voice = .carla
        case "Karl":
            voice = .karl
        case "Dora":
            voice = .dora
        case "Mathieu":
            voice = .mathieu
        case "Celine":
            voice = .celine
        case "Chantal":
            voice = .chantal
        case "Penelope":
            voice = .penelope
        case "Miguel":
            voice = .miguel
        case "Enrique":
            voice = .enrique
        case "Conchita":
            voice = .conchita
        case "Geraint":
            voice = .geraint
        case "Salli":
            voice = .salli
        case "Kimberly":
            voice = .kimberly
        case "Kendra":
            voice = .kendra
        case "Justin":
            voice = .justin
        case "Joey":
            voice = .joey
        case "Ivy":
            voice = .ivy
        case "Raveena":
            voice = .raveena
        case "Emma":
            voice = .emma
        case "Brian":
            voice = .brian
        case "Amy":
            voice = .amy
        case "Russell":
            voice = .russell
        case "Nicole":
            voice = .nicole
        case "Vicki":
            voice = .vicki
        case "Marlene":
            voice = .marlene
        case "Hans":
            voice = .hans
        case "Naja":
            voice = .naja
        case "Mads":
            voice = .mads
        case "Gwyneth":
            voice = .gwyneth
        case "Jacek":
            voice = .jacek
        default:
            return nil
        }
        self.init(rawValue: voice.rawValue)
    }
    
    public var description: String {
        switch self {
        case .joanna:
            return "Joanna"
        case .mizuki:
            return "Mizuki"
        case .filiz:
            return "Filiz"
        case .astrid:
            return "Astrid"
        case .tatyana:
            return "Tatyana"
        case .maxim:
            return "Maxim"
        case .carmen:
            return "Carmen"
        case .ines:
            return "Ines"
        case .cristiano:
            return "Cristiano"
        case .vitoria:
            return "Vitoria"
        case .ricardo:
            return "Ricardo"
        case .maja:
            return "Maja"
        case .jan:
            return "Jan"
        case .ewa:
            return "Ewa"
        case .ruben:
            return "Ruben"
        case .lotte:
            return "Lotte"
        case .liv:
            return "Liv"
        case .giorgio:
            return "Giorgio"
        case .carla:
            return "Carla"
        case .karl:
            return "Karl"
        case .dora:
            return "Dora"
        case .mathieu:
            return "Mathieu"
        case .celine:
            return "Celine"
        case .chantal:
            return "Chantal"
        case .penelope:
            return "Penelope"
        case .miguel:
            return "Miguel"
        case .enrique:
            return "Enrique"
        case .conchita:
            return "Conchita"
        case .geraint:
            return "Geraint"
        case .salli:
            return "Salli"
        case .kimberly:
            return "Kimberly"
        case .kendra:
            return "Kendra"
        case .justin:
            return "Justin"
        case .joey:
            return "Joey"
        case .ivy:
            return "Ivy"
        case .raveena:
            return "Raveena"
        case .emma:
            return "Emma"
        case .brian:
            return "Brian"
        case .amy:
            return "Amy"
        case .russell:
            return "Russell"
        case .nicole:
            return "Nicole"
        case .vicki:
            return "Vicki"
        case .marlene:
            return "Marlene"
        case .hans:
            return "Hans"
        case .naja:
            return "Naja"
        case .mads:
            return "Mads"
        case .gwyneth:
            return "Gwyneth"
        case .jacek:
            return "Jacek"
        }
    }
}

@objc(MBAudioFormat)
public enum AudioFormat: UInt, CustomStringConvertible {
    
    case json
    
    case mp3
    
    case oggVorbis
    
    case pcm
    
    public init?(description: String) {
        let format: AudioFormat
        switch description {
        case "json":
            format = .json
        case "mp3":
            format = .mp3
        case "ogg_vorbis":
            format = .json
        case "pcm":
            format = .pcm
        default:
            return nil
        }
        self.init(rawValue: format.rawValue)
    }
    
    public var description: String {
        switch self {
        case .json:
            return "json"
        case .mp3:
            return "mp3"
        case .oggVorbis:
            return "ogg_vorbis"
        case .pcm:
            return "pcm"
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
    
    /**
     `String` to create audiofile for. Can either be plain text or [`SSML`](https://en.wikipedia.org/wiki/Speech_Synthesis_Markup_Language).
     
     If `SSML` is provided, `TextType` must be `TextType.ssml`.
     */
    open var text: String
    
    
    /**
     Type of text to synthesize.
     
     `SSML` text must be valid `SSML` for request to work.
     */
    open var textType: TextType = .text
    
    
    /**
     Type of voice to use to say text.
     
     Note, `VoiceId` are specific to a `Locale`.
     */
    open var voiceId: VoiceId = .joanna
    
    
    /**
     Audio format for outputted audio file.
     */
    open var outputFormat: AudioFormat = .mp3
    
    /**
     The path of the request URL, not including the hostname or any parameters.
     */
    internal var path: String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "\\!*'();:@&=+$,/<>?%#[] ").inverted)
        return "voice/v1/speak/\(text.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!)"
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
