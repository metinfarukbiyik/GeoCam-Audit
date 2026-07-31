//
//  SplashView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Soğuk açılışta uygulama ikonuyla aynı lacivert zemini ve logoyu gösterir.
struct SplashView: View {

    /// Asset kataloguna bağımlı kalmamak için ikondan örneklenen lacivert.
    private static let background = Color(red: 0.02, green: 0.11, blue: 0.212)

    @State private var isEmphasized = false

    var body: some View {
        GeometryReader { proxy in
            let logoSide = min(
                proxy.size.width * LayoutConstants.Splash.logoWidthRatio,
                LayoutConstants.Splash.maxLogoSize
            )

            ZStack {
                Self.background

                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSide, height: logoSide)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: logoSide * LayoutConstants.Splash.logoCornerRatio,
                            style: .continuous
                        )
                    )
                    .scaleEffect(isEmphasized ? 1 : 0.94)
                    .opacity(isEmphasized ? 1 : 0.9)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .background(Self.background)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: AppConstants.Animation.standard)) {
                isEmphasized = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AppConstants.Info.appName)
    }
}

#Preview {
    SplashView()
}
