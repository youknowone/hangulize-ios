//
//  ContentView.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/15.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

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
    let initialCode = user_state.languageCode ?? hangulize.languages.randomElement()!.code

    var body: some View {
        NavigationView {
            VStack {
                MasterView(code: initialCode)
                    .navigationBarTitle(Text("Languages"))

//                .navigationBarItems(
//                    leading: EditButton(),
//                    trailing: Button(
//                        action: {
//                            withAnimation { self.dates.insert(Date(), at: 0) }
//                        }
//                    ) {
//                        Image(systemName: "plus")
//                    }
//                )
//                DetailView().navigationBarTitle("")
            }.edgesIgnoringSafeArea(.all)
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

    var body: some View {
        List {
            Color.hangulizeBackgroundColor.frame(width: nil, height: upperBarHeight).edgesIgnoringSafeArea(.all)
                .listRowInsets(EdgeInsets())
            ForEach(hangulize!.languages, id: \.self) { lang in
                NavigationLink(destination: DetailView(code: lang.code), tag: lang.code, selection: self.$code) {
                    HStack {
                        Text(lang.label)
                        Spacer()
                        Text(lang.name)
                    }
                }
                .padding([.leading, .trailing])
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color("BackgroundColor"))
        }
        .padding(.top, -upperBarHeight)
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
            backgroundColor = .white
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
    let code: String

    @State var userInput: String = ""
    @State var success: Bool = true
    @ObservedObject var hangulized = Hangulized()

    var selectedLanguage: APILanguage {
        hangulize.language(forCode: code)! // or bug
    }

    var body: some View {
        VStack {
            //     Color.blue.frame(width: nil, height: 140).edgesIgnoringSafeArea(.all)
            Group {
                TextField("Text to Hangulize", text: $userInput, onCommit: {
                    self.hangulized.update(code: self.code, word: self.userInput)
                })
                    .textFieldStyle(HangulizeTextFieldStyle(style: .word))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(Color("TintColor"))
                    .overlay(Button(action: {
                        let utterance = AVSpeechUtterance(string: self.userInput)
                        utterance.voice = AVSpeechSynthesisVoice(language: self.selectedLanguage.iso639_1)
                        speechSynthesizer.speak(utterance)
                        }, label: {
                            Image("SoundImage").padding()
                    }), alignment: .trailing)
                Spacer().frame(height: 0)
                TextField(hangulized.output != "" ? " " : "", text: $hangulized.output)
                    .textFieldStyle(HangulizeTextFieldStyle(style: .hangulized))
//                        .padding(.top)
                    .disabled(true)
                    .animation(.spring())
                    .overlay(ActivityIndicator(isAnimating: $hangulized.updating, style: .medium).padding(.trailing), alignment: .trailing)

                Button(action: {
                    if let word = try? hangulize.api.shuffle(code: self.code).get() {
                        self.userInput = word
                        self.hangulized.update(code: self.code, word: word)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Fill with a random example")
                    }
                }
                LogoImage()
                Text("Hangulize is an application which automatically transcribes a non-Korean word into hangul, the Korean alphabet. Select the original language from the list and enter the word you want to transcribe into hangul in the box above. The hangul transcription will be displayed.")
                Spacer()
            }
        }
        .navigationBarTitle(selectedLanguage.label)
        .padding()
        .padding(.top, upperBarHeight)
        .background(Color("BackgroundColor"))
        .onAppear {
            user_state.languageCode = self.code
        }.edgesIgnoringSafeArea(.vertical)
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
            DetailView(code: "epo").navigationBarTitle("Esperanto")
//        }
        }
    }

#endif
