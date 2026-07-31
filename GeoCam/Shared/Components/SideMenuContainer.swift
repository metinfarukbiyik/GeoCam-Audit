//
//  SideMenuContainer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// İçeriğin üzerine soldan açılan çekmece menü yerleşimi.
/// Tam ekran geometri kullanır; yatayda çentik inset’ini yalnızca bir kez uygular.
struct SideMenuContainer<Content: View, Menu: View>: View {

    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    @ViewBuilder let menu: () -> Menu

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let width = menuWidth(for: proxy.size)
            let leadingInset = proxy.safeAreaInsets.leading
            // Kapalıyken çentik/home tarafına sızmayı önlemek için ekstra kaydırma.
            let hiddenOffset = -(
                width
                + leadingInset
                + LayoutConstants.SideMenu.hiddenOverflowPadding
            )

            ZStack(alignment: .topLeading) {
                content()
                    .frame(width: proxy.size.width, height: proxy.size.height)

                backdrop

                menu()
                    .frame(width: width)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(.background)
                    // Kenardan kenara geometride menüyü güvenli alanın solundan başlat.
                    .padding(.leading, leadingInset)
                    .offset(x: isPresented ? 0 : hiddenOffset)
                    .gesture(dismissGesture)
                    .accessibilityHidden(!isPresented)
                    .allowsHitTesting(isPresented)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .animation(.easeInOut(duration: AppConstants.Animation.standard), value: isPresented)
        }
        // Kamera/önizleme gerçek tam ekran alsın; lacivert letterbox oluşmasın.
        .ignoresSafeArea()
        .background(Color.black)
        // Dönüşte yarı açık / taşmış çekmece kalmasın.
        .onChange(of: verticalSizeClass) { _, _ in
            isPresented = false
        }
        .onChange(of: horizontalSizeClass) { _, _ in
            isPresented = false
        }
    }

    @ViewBuilder
    private var backdrop: some View {
        if isPresented {
            Color.black
                .opacity(LayoutConstants.SideMenu.backdropOpacity)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture { isPresented = false }
                .accessibilityLabel("Menüyü kapat")
                .accessibilityAddTraits(.isButton)
        }
    }

    private var dismissGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                guard value.translation.width < -LayoutConstants.SideMenu.dismissDragThreshold else { return }

                isPresented = false
            }
    }

    private func menuWidth(for size: CGSize) -> CGFloat {
        let isLandscape = size.width > size.height
        let ratio = isLandscape
            ? LayoutConstants.SideMenu.landscapeWidthRatio
            : LayoutConstants.SideMenu.widthRatio
        let maxWidth = isLandscape
            ? LayoutConstants.SideMenu.landscapeMaxWidth
            : LayoutConstants.SideMenu.maxWidth

        return min(size.width * ratio, maxWidth)
    }
}

#Preview {
    @Previewable @State var isPresented = true

    return SideMenuContainer(isPresented: $isPresented) {
        Color.black.ignoresSafeArea()
    } menu: {
        Text("Menü")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
    }
}
