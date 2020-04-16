
import Foundation

static func ciImage2Pixelbuffer( ciimage:CIImage ) -> CVPixelBuffer {
    guard let cgimage =  CIContext(options: nil).createCGImage(ciimage, from: ciimage.extent) else { preconditionFailure() }
    let width = cgimage.width
    let height = cgimage.height
    var pixelBuffer: CVPixelBuffer!
    let attributes : [NSObject:AnyObject] = [
        kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
        kCVPixelBufferMetalCompatibilityKey : true as AnyObject,
        kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
    ]

    var status = CVPixelBufferCreate(
        kCFAllocatorDefault,
        width,
        height,
        kCVPixelFormatType_32BGRA,
        attributes as CFDictionary,
        &pixelBuffer
    )
    if status != kCVReturnSuccess { preconditionFailure() }

    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly);

    defer {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly);
    }

    let bufferAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    let bytesperrow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    let context = CGContext(
        data: bufferAddress,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesperrow,
        space: rgbColorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    );

    context?.draw(cgimage, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
    return pixelBuffer;
}
