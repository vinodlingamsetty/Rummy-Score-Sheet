//
//  QRCodeGenerator.swift
//  Rummy Scorekeeper
//
//  Generates QR codes from strings using CoreImage
//

import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeGenerator {

    /// Generate a QR code image from a string
    /// - Parameters:
    ///   - string: The content to encode (e.g., room code)
    ///   - size: Output image size in points
    /// - Returns: UIImage of the QR code, or nil if generation fails
    static func generate(from string: String, size: CGFloat = 200) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        let scale = size / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
