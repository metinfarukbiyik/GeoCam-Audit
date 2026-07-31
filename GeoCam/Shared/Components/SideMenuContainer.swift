//
//  SideMenuContainer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// İçeriğin üzerine soldan açılan çekmece menü yerleşimi.
struct SideMenuContainer<Content: View, Menu: View>: View {

    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    @ViewBuilder let menu: () -> Menu

    var body: some View {
        GeometryReader { proxy in
            let width = menuWidth(for: proxy.size.width)

            ZStack(alignment: .leading) {
                content()

                backdrop

                menu()
                    .frame(width: width)
                    .frame(maxHeight: .infinity)
                    .background(.background)
                    .offset(x: isPresented ? 0 : -width)
                    .gesture(dismissGesture)
                    .accessibilityHidden(!isPresented)
            }
            .animation(.easeInOut(duration: AppConstants.Animation.standard), value: isPresented)
        }
        .ignoresSafeArea(edges: .bottom)
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

    private func menuWidth(for availableWidth: CGFloat) -> CGFloat {
        min(availableWidth * LayoutConstants.SideMenu.widthRatio, LayoutConstants.SideMenu.maxWidth)
    }
}

#Preview {
    @Previewable @State var isPresented = true

    return SideMenuContainer(isPresented: $isPresented) {
        Color.black.ignoresSafeArea()
    } menu: {
        Text("Menü")
    }
}
