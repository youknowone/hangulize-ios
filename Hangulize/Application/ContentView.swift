//
//  ContentView.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/15.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import Combine
import SwiftUI

var appScene: UIWindowScene!
var upperBarHeight: CGFloat!

struct ApplicationView: View {
    let scene: UIWindowScene

    var body: some View {
        Group {
            if hangulize != nil {
                ContentView()
            } else {
                NetworkErrorView()
            }
        }
        .onAppear {
            appScene = self.scene
        }
    }
}

var navigationHeight: CGFloat = 104.0

struct ContentView: View {
    let initialLanguage = hangulize.language(forCode: userState.languageCode ?? hangulize.languages.randomElement()!.code)!

    var body: some View {
        NavigationView {
            VStack {
                MasterView(code: initialLanguage.code)
                    .navigationBarTitle(Text("Languages"))
            }
            .edgesIgnoringSafeArea(.all)
            // iPad requires second view to show
            DetailView(language: initialLanguage).navigationBarTitle(initialLanguage.label)
        }

        .background(NavigationConfigurator { nc in
            // navigationHeight = nc.navigationBar.frame.height
            nc.navigationBar.barTintColor = .blue
            nc.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        })
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .background(/*@START_MENU_TOKEN@*/Color("BackgroundColor")/*@END_MENU_TOKEN@*/)
        .onAppear {
            let statusHeight = appScene.statusBarManager!.statusBarFrame.height
            upperBarHeight = statusHeight + navigationHeight
        }
    }
}

struct LogoImage: View {
    var body: some View {
        Image("Logo").resizable()
            .aspectRatio(3.29, contentMode: .fit)
    }
}

struct MasterView: View {
    @State var code: String?
    @State var ordering: Bool = userState.ordering // FIXME:
    @State var languages: [APILanguage] = hangulize.languages.sorted(by: userState.ordering ? {
        $0.label < $1.label
    } : {
        $0.name < $1.name
    })

    var body: some View {
        let _ordering = Binding(
            get: { userState.ordering },
            set: {
                userState.ordering = $0
                self.ordering = $0
                self.languages.sort(by: $0 ? {
                    $0.label < $1.label
                } : {
                    $0.name < $1.name
                })
            }
        )

        return List {
            Color.hangulizeBackgroundColor.frame(width: nil, height: upperBarHeight * 3).edgesIgnoringSafeArea(.all)
                .listRowInsets(EdgeInsets())
            ForEach(languages, id: \.self) { lang in
                NavigationLink(destination: DetailView(language: lang), tag: lang.code, selection: self.$code) {
                    // TODO: fix to use zorder
                    if self.ordering {
                        HStack {
                            Text(lang.label)
                            Spacer()
                            Text(lang.name)
                        }
                    } else {
                        HStack {
                            Text(lang.name)
                            Spacer()
                            Text(lang.label)
                        }
                    }
                }
                .padding([.leading, .trailing])
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color("BackgroundColor"))
        }
        .navigationBarItems(
            trailing:
            Toggle(isOn: _ordering, label: { Text("Order") })
        )
        .padding(.top, -upperBarHeight * 3)
        .edgesIgnoringSafeArea([])
    }
}

public struct HangulizeTextFieldStyle: TextFieldStyle {
    enum Style {
        case word
        case hangulized
    }

    let style: Style

    public func _body(configuration: TextField<Self._Label>) -> some View {
        var foregroundColor: Color
        var backgroundColor: Color
        switch style {
        case .word:
            foregroundColor = .hangulizeAccentColor
            backgroundColor = Color(UIColor.systemBackground)
        case .hangulized:
            foregroundColor = .primary
            backgroundColor = Color("HighlightBackgroundColor")
        }

        return configuration
            .padding(6) // Set the inner Text Field Padding
            .font(/*@START_MENU_TOKEN@*/ .title/*@END_MENU_TOKEN@*/)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.gray
                        .opacity(1), lineWidth: 0.5))
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
    }
}

import AVFoundation

struct DetailView: View {
    let language: APILanguage

    @State var userInput: String = ""
    @ObservedObject var hangulized = HangulizeView()
    @ObservedObject var shuffled = ShuffleView()

    var body: some View {
        let shuffledSubject = CurrentValueSubject<String, Never>(shuffled.result)
        _ = shuffledSubject.receive(on: RunLoop.main)
            .sink { value in
                guard value != "", self.userInput != value else {
                    return
                }

                self.userInput = value
                self.hangulized.updateInBackground(with: (code: self.language.code, word: self.userInput))
            }

        let speechButton = Button(action: speakWord, label: {
            Image("SoundImage").padding()
        })

        return VStack {
            Group {
                TextField("Text to Hangulize", text: $userInput, onCommit: {
                    self.hangulized.updateInBackground(with: (code: self.language.code, word: self.userInput)) {
                        impactFeedbackGenerator.impactOccurred()
                    }
                    userState.lastInput = self.userInput
                })
                    .textFieldStyle(HangulizeTextFieldStyle(style: .word))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(Color("TintColor"))
                    .overlay(HStack {
                        if self.language.hasVoice {
                            speechButton
                        }
                    }, alignment: .trailing)
                Spacer().frame(height: 0)
                TextField(hangulized.success ? " " : "", text: $hangulized.result)
                    .textFieldStyle(HangulizeTextFieldStyle(style: .hangulized))
//                        .padding(.top)
                    .disabled(true)
                    .animation(.spring())
                    .overlay(ActivityIndicator(isAnimating: $hangulized.updating, style: .medium).padding(.trailing), alignment: .trailing)

                Button(action: {
                    self.executeShuffle()
                }) {
                    HStack {
                        Spacer()
                        Text("Fill with a random example")
                    }
                }
                .disabled(shuffled.updating)
                LogoImage()
                Text("Hangulize is an application which automatically transcribes a non-Korean word into hangul, the Korean alphabet. Select the original language from the list and enter the word you want to transcribe into hangul in the box above. The hangul transcription will be displayed.")
                Spacer()
            }
        }
        .navigationBarTitle(language.label)
        .padding()
        .padding(.top, upperBarHeight)
        .background(Color("BackgroundColor"))
        .onAppear {
            if userState.languageCode == self.language.code {
                if let lastInput = userState.lastInput {
                    self.shuffled.result = lastInput
                }
            } else {
                userState.languageCode = self.language.code
                userState.lastInput = nil
            }
            if self.userInput == "" {
                self.executeShuffle()
            }
        }.edgesIgnoringSafeArea(.vertical)
    }

    func executeShuffle() {
        shuffled.updateInBackground(with: language.code)
    }

    func speakWord() {
        let utterance = AVSpeechUtterance(string: userInput)
        utterance.voice = AVSpeechSynthesisVoice(language: language.iso639_1)
        speechSynthesizer.speak(utterance)
    }
}

#if DEBUG

    // struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
    // }

    struct MasterView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                MasterView(code: "").navigationBarTitle("Languages")
            }
        }
    }

    struct DetailView_Previews: PreviewProvider {
        static var previews: some View {
//        NavigationView {
            DetailView(language: hangulize.language(forCode: "epo")!)
                .navigationBarTitle("Esperanto")
//        }
        }
    }

#endif
