//
//  AppWatermarkDrawer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// Damgalı fotoğraf/video köşesine uygulama filigranı çizer.
/// Uygulama adı + orijinallik satırı ile kaydın güvenilirliğini vurgular.
nonisolated enum AppWatermarkDrawer {

    /// Görüntünün sağ alt köşesine yarı saydam filigran ekler.
    static func apply(to image: UIImage, language: AppLanguage) -> UIImage {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return image }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
            drawText(in: size, language: language)
        }
    }

    /// Video Core Animation hiyerarşisine eklenecek filigran katmanı.
    /// `parentLayer.isGeometryFlipped == false` (sol alt orijin) varsayılır.
    static func makeLayer(renderSize: CGSize, language: AppLanguage) -> CALayer {
        let metrics = textMetrics(for: renderSize.width, language: language)
        let inset = renderSize.width * OverlayConstants.Watermark.insetRatio

        // UIKit sağ alt → CA sol alt orijine çevir.
        let layer = CATextLayer()
        layer.string = metrics.attributed
        layer.contentsScale = UIScreen.main.scale
        layer.alignmentMode = .right
        layer.isWrapped = true
        layer.frame = CGRect(
            x: renderSize.width - metrics.size.width - inset,
            y: inset,
            width: ceil(metrics.size.width),
            height: ceil(metrics.size.height)
        )
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Float(OverlayConstants.Watermark.shadowOpacity)
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = OverlayConstants.Watermark.shadowRadius

        return layer
    }

    // MARK: - Private

    private static func drawText(in canvasSize: CGSize, language: AppLanguage) {
        let metrics = textMetrics(for: canvasSize.width, language: language)
        let inset = canvasSize.width * OverlayConstants.Watermark.insetRatio
        let origin = CGPoint(
            x: canvasSize.width - metrics.size.width - inset,
            y: canvasSize.height - metrics.size.height - inset
        )

        shadowed(metrics.attributed).draw(at: CGPoint(x: origin.x, y: origin.y + 1))
        metrics.attributed.draw(at: origin)
    }

    private static func textMetrics(
        for width: CGFloat,
        language: AppLanguage
    ) -> (attributed: NSAttributedString, size: CGSize) {
        let titleSize = max(
            OverlayConstants.Watermark.minFontSize,
            width * OverlayConstants.Watermark.fontSizeRatio
        )
        let subtitleSize = max(
            OverlayConstants.Watermark.minSecondaryFontSize,
            titleSize * OverlayConstants.Watermark.secondaryFontScale
        )

        let titleFont = UIFont.systemFont(ofSize: titleSize, weight: .semibold)
        let subtitleFont = UIFont.systemFont(ofSize: subtitleSize, weight: .medium)
        let lineSpacing = titleSize * OverlayConstants.Watermark.lineSpacingRatio

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        paragraph.lineSpacing = lineSpacing

        let result = NSMutableAttributedString()
        result.append(
            NSAttributedString(
                string: AppConstants.Info.appName,
                attributes: [
                    .font: titleFont,
                    .foregroundColor: UIColor.white.withAlphaComponent(OverlayConstants.Watermark.opacity),
                    .paragraphStyle: paragraph
                ]
            )
        )
        result.append(NSAttributedString(string: "\n"))
        result.append(
            NSAttributedString(
                string: language.t(.watermarkAuthenticity),
                attributes: [
                    .font: subtitleFont,
                    .foregroundColor: UIColor.white.withAlphaComponent(OverlayConstants.Watermark.secondaryOpacity),
                    .paragraphStyle: paragraph
                ]
            )
        )

        let bounds = result.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        return (result, CGSize(width: ceil(bounds.width), height: ceil(bounds.height)))
    }

    /// Gölge, asıl metnin font/paragraph yapısını korur; yalnızca renk değişir.
    private static func shadowed(_ attributed: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: attributed)
        let fullRange = NSRange(location: 0, length: result.length)
        result.enumerateAttributes(in: fullRange) { attributes, range, _ in
            var next = attributes
            next[.foregroundColor] = UIColor.black.withAlphaComponent(OverlayConstants.Watermark.shadowOpacity)
            result.setAttributes(next, range: range)
        }
        return result
    }
}
