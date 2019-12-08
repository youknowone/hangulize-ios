//
//  Global.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/12/08.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

let speechSynthesizer = AVSpeechSynthesizer()
let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
var hangulize: HangulizeService! = HangulizeService()

final class HangulizeService: ObservableObject {
    @State var languages: [APILanguage]

    let api = API()

    init?() {
        guard let langs = try? api.languages().get() else {
            return nil
        }
        languages = langs
        sort(byKorean: userState.ordering)
    }

    func sort(byKorean ordering: Bool) {
        languages.sort(by: ordering ? { $0.label > $1.label } : { $0.name > $1.name })
    }

    func language(forCode code: String) -> APILanguage? {
        languages.first(where: { $0.code == code })
    }
}

extension APILanguage {
    var hasVoice: Bool {
        AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix(self.iso639_1)
        }.count > 0
    }
}
