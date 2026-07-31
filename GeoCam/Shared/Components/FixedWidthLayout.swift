//
//  FixedWidthLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Alt görünümün ideal genişliğini yok sayıp sabit genişlik dayatır.
/// SwiftUI'da uzun Text + Material kombinasyonunun taşımasını engeller.
struct FixedWidthLayout: Layout {
    var width: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }

        let fitted = subview.sizeThatFits(
            ProposedViewSize(width: width, height: proposal.height)
        )
        return CGSize(width: width, height: fitted.height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else { return }

        subview.place(
            at: CGPoint(x: bounds.minX, y: bounds.minY),
            proposal: ProposedViewSize(width: width, height: bounds.height)
        )
    }
}
