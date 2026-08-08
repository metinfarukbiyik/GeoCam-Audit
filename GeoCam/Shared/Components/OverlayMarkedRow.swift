//
//  OverlayMarkedRow.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Simge ile içeriği katmanın yaslama yönüne göre sıralar.
/// Sağa yaslıyken simge içeriğin sağına geçer, böylece satır aynalanır.
struct OverlayMarkedRow<Mark: View, Content: View>: View {

    let alignment: OverlayHorizontalAlignment
    var verticalAlignment: VerticalAlignment = .top
    var spacing: CGFloat = LayoutConstants.Spacing.small
    @ViewBuilder let mark: () -> Mark
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: verticalAlignment, spacing: spacing) {
            switch alignment {
            case .leading:
                mark()
                content()
            case .trailing:
                content()
                mark()
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(OverlayHorizontalAlignment.allCases) { alignment in
            OverlayMarkedRow(alignment: alignment) {
                Image(systemName: "mappin.and.ellipse")
            } content: {
                Text("Beşirli, Trabzon Merkez")
                    .frame(maxWidth: .infinity, alignment: alignment.frameAlignment)
            }
            .frame(width: 260)
        }
    }
    .padding()
}
