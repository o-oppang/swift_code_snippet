func transform_pixelbuffer(_ outputBuf: CMSampleBuffer) -> CMSampleBuffer?
    {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(outputBuf) else {
            preconditionFailure()
        }

        var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo()
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let size = CGSize(width: width, height: height)
        var ciImg = CIImage.init(cvPixelBuffer: pixelBuffer, options: nil)
        let aff = CGAffineTransform(scaleX: -1.0, y: -1.0).translatedBy(x: -size.width, y: -size.height)
        ciImg = ciImg.transformed(by: aff)
        guard let cgimage = CIContext().createCGImage(ciImg, from: CGRect( origin: CGPoint.zero, size: size )) else { return nil }

        var newPixelBuffer : CVPixelBuffer? = nil
        let dictionary = [
            kCVPixelBufferMetalCompatibilityKey:true,
            kCVPixelBufferCGImageCompatibilityKey:true,
            kCVPixelBufferCGBitmapContextCompatibilityKey:true
        ] as CFDictionary

        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32BGRA,
                                         dictionary,
                                         &newPixelBuffer)
        if status != kCVReturnSuccess {
            preconditionFailure()
        }
        guard let newPbUnwrapped = newPixelBuffer else { preconditionFailure() }

        CVPixelBufferLockBaseAddress(newPbUnwrapped, CVPixelBufferLockFlags(rawValue: 0))
        let baseAdd = CVPixelBufferGetBaseAddress(newPbUnwrapped)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let context = CGContext(data: baseAdd, width: width, height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(newPbUnwrapped),
                                space: colorSpace,
                                bitmapInfo: info)

        context?.draw(cgimage, in: CGRect(origin: CGPoint.zero, size: size))

        var videoFormatDescription: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: newPbUnwrapped,
            formatDescriptionOut: &videoFormatDescription)

        guard let videoFormatDescriptionUnwrapped = videoFormatDescription else {
            preconditionFailure()
        }
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: newPbUnwrapped,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: videoFormatDescriptionUnwrapped,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer)

        CVPixelBufferUnlockBaseAddress(newPbUnwrapped, CVPixelBufferLockFlags(rawValue: 0))
        return sampleBuffer
    }
