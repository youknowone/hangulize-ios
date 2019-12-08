//
//  UserState.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/23.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import Combine
import UIKit

final class UserState: UserDefaults, ObservableObject {
    var languageCode: String? {
        get {
            string(forKey: "LanguageCode")
        }
        set {
            objectWillChange.send()
            set(newValue, forKey: "LanguageCode")
        }
    }

    var lastInput: String? {
        get {
            string(forKey: "LastInput")
        }
        set {
            set(newValue, forKey: "LastInput")
        }
    }

    var ordering: Bool {
        get {
            bool(forKey: "LanguageOrdering")
        }
        set {
            objectWillChange.send()
            set(newValue, forKey: "LanguageOrdering")
            hangulize.sort(byKorean: newValue)
        }
    }
}

let userState = UserState()
