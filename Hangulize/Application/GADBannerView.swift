//
//  GADBannerView.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/12/07.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

private struct GADBannerViewController: UIViewControllerRepresentable {
    let adUnitId: String

    func makeUIViewController(context _: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)

        let viewController = UIViewController()
        #if DEBUG
            view.adUnitID = "ca-app-pub-3940256099942544/1712485313"
        #else
            view.adUnitID = adUnitId
        #endif
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

struct GADBanner: View {
    let adUnitId: String

    var body: some View {
        HStack {
            Spacer()
            GADBannerViewController(adUnitId: adUnitId).frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height, alignment: .center)
            Spacer()
        }
    }
}
