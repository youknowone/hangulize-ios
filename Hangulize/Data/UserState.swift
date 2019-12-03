//
//  UserState.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/23.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import SwiftUI

final class UserState: UserDefaults {
    var languageCode: String? {
        get {
            string(forKey: "LanguageCode")
        }
        set {
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
}

let userState = UserState()
