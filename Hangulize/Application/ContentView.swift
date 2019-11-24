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

struct DetailView: View {
    let code: String

    @State var userInput: String = ""
    @State var hangulized: String = ""
    @State var success: Bool = true

    var selectedLanguage: APILanguage {
        hangulize.language(forCode: code)! // or bug
    }

    var body: some View {
        VStack {
            //     Color.blue.frame(width: nil, height: 140).edgesIgnoringSafeArea(.all)
            Group {
                Group {
                    TextField("Text to Hangulize", text: $userInput, onCommit: {
                        if let result = try? hangulize.api.hangulize(code: self.code, word: self.userInput).get() {
                            self.hangulized = result.result
                            self.success = true
                        } else {
                            self.success = false
                        }
                    })
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField(" ", text: $hangulized)
                        .disabled(true)
                        .padding(.top, -8.0)
                        .background(Color.clear)
                }.textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(/*@START_MENU_TOKEN@*/ .largeTitle/*@END_MENU_TOKEN@*/)

                Button(action: {}) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
