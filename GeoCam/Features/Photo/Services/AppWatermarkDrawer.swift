//
//  AppWatermarkDrawer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// Damgalı fotoğraf/videoya köşe filigranları çizer.
/// Sol alt: onay ikonu + doğrulama cümlesi (beyaz).
/// Sağ alt: altlı üstlü GeoCam / audit marka yazısı.
nonisolated enum AppWatermarkDrawer {

    /// Görüntünün alt köşelerine filigran ekler.
    static func apply(to image: UIImage, language: AppLanguage) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }

        let left = makeBadge(
            kind: .verified,
            canvasWidth: size.width,
            language: language
        )
        let right = makeBadge(
            kind: .brand,
            canvasWidth: size.width,
            language: language
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
            if let left {
                left.image.draw(at: origin(for: left, side: .leading, in: size))
            }
            if let right {
                right.image.draw(at: origin(for: right, side: .trailing, in: size))
            }
        }
    }

    /// Video Core Animation hiyerarşisine eklenecek filigran katmanı.
    /// `parentLayer.isGeometryFlipped == false` (sol alt orijin) varsayılır.
    static func makeLayer(renderSize: CGSize, language: AppLanguage) -> CALayer {
        let parent = CALayer()
        parent.frame = CGRect(origin: .zero, size: renderSize)

        if let left = makeBadge(kind: .verified, canvasWidth: renderSize.width, language: language) {
            parent.addSublayer(layer(for: left, side: .leading, in: renderSize))
        }
        if let right = makeBadge(kind: .brand, canvasWidth: renderSize.width, language: language) {
            parent.addSublayer(layer(for: right, side: .trailing, in: renderSize))
        }

        return parent
    }

    // MARK: - Private

    private enum Side {
        case leading
        case trailing
    }

    private enum Kind {
        case verified
        case brand
    }

    private static func origin(
        for badge: (image: UIImage, shadowPadding: CGFloat),
        side: Side,
        in canvasSize: CGSize
    ) -> CGPoint {
        let inset = canvasSize.width * OverlayConstants.Watermark.insetRatio - badge.shadowPadding
        let x = switch side {
        case .leading: inset
        case .trailing: canvasSize.width - badge.image.size.width - inset
        }

        return CGPoint(
            x: x,
            y: canvasSize.height - badge.image.size.height - inset
        )
    }

    private static func layer(
        for badge: (image: UIImage, shadowPadding: CGFloat),
        side: Side,
        in renderSize: CGSize
    ) -> CALayer {
        let inset = renderSize.width * OverlayConstants.Watermark.insetRatio - badge.shadowPadding
        let x = switch side {
        case .leading: inset
        case .trailing: renderSize.width - badge.image.size.width - inset
        }

        let layer = CALayer()
        layer.contents = badge.image.cgImage
        layer.contentsGravity = .resizeAspect
        layer.frame = CGRect(
            x: x,
            y: inset,
            width: badge.image.size.width,
            height: badge.image.size.height
        )
        return layer
    }

    private static func makeBadge(
        kind: Kind,
        canvasWidth: CGFloat,
        language: AppLanguage
    ) -> (image: UIImage, shadowPadding: CGFloat)? {
        let metrics = Metrics(kind: kind, canvasWidth: canvasWidth, language: language)
        guard metrics.badgeSize.width > 0, metrics.badgeSize.height > 0 else { return nil }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        let image = UIGraphicsImageRenderer(size: metrics.badgeSize, format: format).image { context in
            context.cgContext.setShadow(
                offset: CGSize(width: 0, height: metrics.shadowYOffset),
                blur: metrics.shadowBlur,
                color: UIColor.black.withAlphaComponent(OverlayConstants.Watermark.shadowOpacity).cgColor
            )

            metrics.icon?.draw(in: metrics.iconRect)
            metrics.text.draw(in: metrics.textRect)
        }

        return (image, metrics.padding)
    }

    private static var brandBlue: UIColor {
        UIColor(
            red: OverlayConstants.Watermark.brandBlueRed,
            green: OverlayConstants.Watermark.brandBlueGreen,
            blue: OverlayConstants.Watermark.brandBlueBlue,
            alpha: 1
        )
    }

    private struct Metrics {
        let icon: UIImage?
        let text: NSAttributedString
        let iconRect: CGRect
        let textRect: CGRect
        let badgeSize: CGSize
        let shadowBlur: CGFloat
        let shadowYOffset: CGFloat
        let padding: CGFloat

        init(kind: Kind, canvasWidth: CGFloat, language: AppLanguage) {
            let titleSize = max(
                OverlayConstants.Watermark.minFontSize,
                canvasWidth * OverlayConstants.Watermark.fontSizeRatio
            )

            shadowBlur = max(
                OverlayConstants.Watermark.minShadowBlur,
                titleSize * OverlayConstants.Watermark.shadowBlurRatio
            )
            shadowYOffset = titleSize * OverlayConstants.Watermark.shadowYOffsetRatio
            padding = shadowBlur + shadowYOffset

            text = Self.makeText(kind: kind, titleSize: titleSize, language: language)
            let textSize = Self.boundingSize(of: text)

            let iconHeight = titleSize * OverlayConstants.Watermark.iconScale
            let spacing = titleSize * OverlayConstants.Watermark.iconSpacingRatio

            switch kind {
            case .verified:
                icon = Self.makeSymbol(
                    named: OverlayConstants.Watermark.verifiedIconName,
                    height: iconHeight,
                    color: .white
                )
                let iconSize = icon.map { image -> CGSize in
                    let ratio = image.size.height > 0 ? image.size.width / image.size.height : 1
                    return CGSize(width: iconHeight * ratio, height: iconHeight)
                } ?? .zero
                let contentHeight = max(textSize.height, iconSize.height)
                badgeSize = CGSize(
                    width: ceil(iconSize.width + spacing + textSize.width + padding * 2),
                    height: ceil(contentHeight + padding * 2)
                )
                iconRect = CGRect(
                    x: padding,
                    y: padding + (contentHeight - iconSize.height) / 2,
                    width: iconSize.width,
                    height: iconSize.height
                )
                textRect = CGRect(
                    x: padding + iconSize.width + spacing,
                    y: padding + (contentHeight - textSize.height) / 2,
                    width: ceil(textSize.width),
                    height: ceil(textSize.height)
                )

            case .brand:
                icon = nil
                iconRect = .zero
                badgeSize = CGSize(
                    width: ceil(textSize.width + padding * 2),
                    height: ceil(textSize.height + padding * 2)
                )
                textRect = CGRect(
                    x: padding,
                    y: padding,
                    width: ceil(textSize.width),
                    height: ceil(textSize.height)
                )
            }
        }

        private static func makeSymbol(named name: String, height: CGFloat, color: UIColor) -> UIImage? {
            let configuration = UIImage.SymbolConfiguration(pointSize: height, weight: .semibold)

            return UIImage(systemName: name, withConfiguration: configuration)?
                .withTintColor(color, renderingMode: .alwaysOriginal)
        }

        private static func makeText(
            kind: Kind,
            titleSize: CGFloat,
            language: AppLanguage
        ) -> NSAttributedString {
            switch kind {
            case .verified:
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .left

                return NSAttributedString(
                    string: language.t(.watermarkVerified),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: titleSize, weight: .bold),
                        .foregroundColor: UIColor.white,
                        .paragraphStyle: paragraph
                    ]
                )

            case .brand:
                return makeBrandWordmark(titleSize: titleSize)
            }
        }

        /// Altlı üstlü: GeoCam (beyaz) / Audit (mavi); sol filigranla aynı bold punto.
        private static func makeBrandWordmark(titleSize: CGFloat) -> NSAttributedString {
            let font = UIFont.systemFont(ofSize: titleSize, weight: .bold)
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            paragraph.lineSpacing = titleSize * OverlayConstants.Watermark.brandLineSpacingRatio

            let result = NSMutableAttributedString()
            result.append(
                NSAttributedString(
                    string: "GeoCam\n",
                    attributes: [
                        .font: font,
                        .foregroundColor: UIColor.white,
                        .paragraphStyle: paragraph
                    ]
                )
            )
            result.append(
                NSAttributedString(
                    string: "Audit",
                    attributes: [
                        .font: font,
                        .foregroundColor: AppWatermarkDrawer.brandBlue,
                        .paragraphStyle: paragraph
                    ]
                )
            )

            return result
        }

        private static func boundingSize(of text: NSAttributedString) -> CGSize {
            let bounds = text.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )

            return CGSize(width: ceil(bounds.width), height: ceil(bounds.height))
        }
    }
}
