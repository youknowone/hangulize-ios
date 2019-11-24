//
//  Assets.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/24.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import SwiftUI

extension Color {
    static let hangulizeAccentColor = Color("TintColor")
    static let hangulizeBackgroundColor = Color("BackgroundColor")
    static let resultBackgroundColor = Color("HighlightedBackgroundColor")
}

extension UIColor {
    static let hangulizeTintColor = UIColor(named: "TintColor")!
    static let hangulizeBackgroundColor = UIColor(named: "BackgroundColor")!
    static let resultBackgroundColor = UIColor(named: "HighlightedBackgroundColor")!
}

extension UINavigationBarAppearance {
    static let hangulize: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(named: "BackgroundColor")
        return appearance
    }()
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context _: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context _: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            configure(nc)
        }
    }
}
