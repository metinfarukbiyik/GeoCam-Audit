//
//  OverlayCorner.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Bilgi katmanının yaslandığı dikey kenar.
/// Yatayda yalnızca en sol / en sağ; ortaya alınamaz.
/// Dikey konum `verticalPosition` (0...1) ile ayrı tutulur.
nonisolated enum OverlayCorner: String, CaseIterable, Identifiable, Codable, Sendable {
    case leading
    case trailing

    var id: String { rawValue }

    static let `default`: OverlayCorner = .leading

    var horizontalAlignment: OverlayHorizontalAlignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .leading: language.t(.cornerBottomLeading)
        case .trailing: language.t(.cornerBottomTrailing)
        }
    }

    /// Katmanın sol-üst köşe noktası.
    /// `verticalPosition` 0 = üst güvenli sınır, 1 = filigranın hemen üstü.
    func origin(
        contentSize: CGSize,
        in frameSize: CGSize,
        verticalPosition: CGFloat
    ) -> CGPoint {
        guard frameSize.width > 0, frameSize.height > 0 else { return .zero }

        let insetX = frameSize.width * OverlayConstants.horizontalInsetRatio
        let width = min(max(contentSize.width, 0), frameSize.width)
        let height = min(max(contentSize.height, 0), frameSize.height)
        let range = Self.verticalRange(contentHeight: height, in: frameSize)
        let t = OverlayConstants.VerticalPosition.clamped(verticalPosition)

        let x = self == .leading
            ? insetX
            : frameSize.width - width - insetX
        let y = range.lowerBound + (range.upperBound - range.lowerBound) * t

        return CGPoint(x: max(0, x), y: y)
    }

    /// İçerik yüksekliğine göre sürükleme / yerleşim dikey aralığı.
    static func verticalRange(contentHeight: CGFloat, in frameSize: CGSize) -> ClosedRange<CGFloat> {
        let topInset = frameSize.height * OverlayConstants.verticalInsetRatio
        let bottomInset = OverlayConstants.bottomContentInset(forWidth: frameSize.width)
        let minY = topInset
        let maxY = frameSize.height - max(contentHeight, 0) - bottomInset

        return minY...max(minY, maxY)
    }

    /// Piksel cinsinden Y değerini 0...1 dikey konuma çevirir.
    static func normalizedVerticalPosition(y: CGFloat, contentHeight: CGFloat, in frameSize: CGSize) -> CGFloat {
        let range = verticalRange(contentHeight: contentHeight, in: frameSize)
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return OverlayConstants.VerticalPosition.defaultValue }

        return OverlayConstants.VerticalPosition.clamped((y - range.lowerBound) / span)
    }

    /// İçerik merkezinin yatay yarısına göre kenar.
    static func nearestEdge(to point: CGPoint, in frameSize: CGSize) -> OverlayCorner {
        guard frameSize.width > 0 else { return .default }

        return point.x < frameSize.width / 2 ? .leading : .trailing
    }

    static func migrating(
        from position: OverlayPosition,
        alignment: OverlayHorizontalAlignment
    ) -> OverlayCorner {
        alignment == .trailing ? .trailing : .leading
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        switch raw {
        case Self.leading.rawValue, "bottomLeading", "topLeading":
            self = .leading
        case Self.trailing.rawValue, "bottomTrailing", "topTrailing":
            self = .trailing
        default:
            self = .default
        }
    }
}
