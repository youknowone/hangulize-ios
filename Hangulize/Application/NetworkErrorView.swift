//
//  NetworkErrorView.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/23.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context _: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context _: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct NetworkErrorView: View {
    @State var connecting = false

    var body: some View {
        VStack {
            LogoImage()
            Text("Server not available. Please try reconnect when network is available.")
            Spacer()
            ActivityIndicator(isAnimating: $connecting, style: .large)
            Button(action: {
                self.connecting = true
                DispatchQueue.global(qos: .userInitiated).async {
                    if let newService = HangulizeService() {
                        DispatchQueue.main.sync {
                            hangulize = newService
                            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!
                            keyWindow.rootViewController = UIHostingController(rootView: ContentView())
                        }
                    } else {
                        sleep(1)
                        DispatchQueue.main.sync {
                            self.connecting = false
                        }
                    }
                }

            }) {
                Text("Reconnect")
            }
            Spacer()
        }.padding()
    }
}

struct NetworkErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorView()
    }
}
