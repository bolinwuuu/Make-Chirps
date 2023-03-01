//
//  Spectrogram.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 1/27/23.
//

import Foundation
import UIKit
import Accelerate
import Darwin
import SwiftUI
import Charts

extension Run_Chirp {
    
    func initSpectrogram() {

        bufferCount = 40
        
        let freqCount = freq.count
        
        piece_len = Int(freqCount / bufferCount)
        
        let sc_no_padding = Int(pow(2, ceil(log2(Double(piece_len)))))
        
        last_exp = Int(log2(Double(sc_no_padding / 2))) - 1
        
        let len_log_no_padding = (last_exp + 1) * Int(pow(2, Double(last_exp)))
        
        zero_padding = max(Int(pow(2, floor(log2(9000 / Double(len_log_no_padding))))), 1)
        
        sampleCount = sc_no_padding * zero_padding
        
        splitComplexRealInput = [Float](repeating: 0, count: sampleCount)
        splitComplexImaginaryInput = [Float](repeating: 0, count: sampleCount)
        
        magnitudes = [Float](repeating: 0, count: sampleCount)
        
        len_log = zero_padding * len_log_no_padding
        
        mag_log = [Float](repeating: 0, count: len_log)
        
        start_idx = Int(floor(Double(sampleCount) / (fsamp / 20)))
        
        timeDomainBuffer = [Float](repeating: 0, count: piece_len)
        freqDomainValues = []
        freqDomainValues.reserveCapacity(len_log * bufferCount * bin_duplicate)
        
        hannWindow = vDSP.window(ofType: Float.self,
                                 usingSequence: .hanningDenormalized,
                                 count: piece_len,
                                 isHalfWindow: false)
        
    }
    
    func genSpectrogram() -> UIImage {
        fill_freqDomainValues()
        
        let maxFreqVal = vDSP.maximum(freqDomainValues)
        let maxFloat = maxFreqVal * 1.2
        let minFloat = 0 - maxFreqVal * 0.1
        
        let rgbImageFormat: vImage_CGImageFormat = {
            guard let format = vImage_CGImageFormat(
                    //bitsPerComponent: 8,
                    //bitsPerPixel: 8 * 4,
                    bitsPerComponent: 8,
                    bitsPerPixel: 8 * 4,
                    colorSpace: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                    renderingIntent: .defaultIntent) else {
                fatalError("Can't create image format.")
            }
            
            return format
        }()
        
        /// RGB vImage buffer that contains a vertical representation of the audio spectrogram.
        var rgbImageBuffer: vImage_Buffer = {
            guard let buffer = try? vImage_Buffer(
                width: len_log,        //sampleCount / 2,
                height: bufferCount,
                bitsPerPixel: rgbImageFormat.bitsPerPixel) else {
                fatalError("Unable to initialize image buffer.")
            }
            return buffer
        }()

        /// RGB vImage buffer that contains a horizontal representation of the audio spectrogram.
        var rotatedImageBuffer: vImage_Buffer = {
            guard let buffer = try? vImage_Buffer(
                width: bufferCount,
                height: len_log,       //sampleCount / 2,
                bitsPerPixel: rgbImageFormat.bitsPerPixel)  else {
                fatalError("Unable to initialize rotated image buffer.")
            }
            return buffer
        }()
        
        //let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
        //let minFloats: [Float] = [255, 0, 0, 0]
        let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
        let minFloats: [Float] = [255, minFloat, minFloat, minFloat]
        
        freqDomainValues.withUnsafeMutableBufferPointer {
            var planarImageBuffer = vImage_Buffer(
                data: $0.baseAddress!,
                height: vImagePixelCount(bufferCount),
                width: vImagePixelCount(len_log),  //sampleCount / 2),
                rowBytes: (len_log) * MemoryLayout<Float>.stride)
                //rowBytes: sampleCount / 2 * MemoryLayout<Float>.stride)
            
            vImageConvert_PlanarFToARGB8888(
                &planarImageBuffer,
                &planarImageBuffer,
                &planarImageBuffer,
                &planarImageBuffer,
                &rgbImageBuffer,
                maxFloats,
                minFloats,
                vImage_Flags(kvImageNoFlags))
        }
        
        vImageTableLookUp_ARGB8888(
            &rgbImageBuffer,
            &rgbImageBuffer,
            nil,
            &redTable,
            &greenTable,
            &blueTable,
            vImage_Flags(kvImageNoFlags))
        
        vImageRotate90_ARGB8888(
            &rgbImageBuffer,
            &rotatedImageBuffer,
            UInt8(kRotate90DegreesCounterClockwise),
            [UInt8()],
            vImage_Flags(kvImageNoFlags))
        
        let result = try? rotatedImageBuffer.createCGImage(format: rgbImageFormat)
        //let result = try? rgbImageBuffer.createCGImage(format: rgbImageFormat)
        
        
        //let success = saveImage(image: UIImage(cgImage: result!))
        //print(success)
        return UIImage(cgImage: result!)
    }
    
    func fill_freqDomainValues() {
        fill_mag_log(i: 0)
        
        for _ in 0..<bin_duplicate {
            freqDomainValues += mag_log
        }
        
        for i in stride(from: piece_len, to: bufferCount * piece_len, by: piece_len) {

            
            fill_mag_log(i: i)

            
            
            let mean_mag = vDSP.multiply(addition: (mag_log, freqDomainValues[freqDomainValues.count - len_log..<freqDomainValues.count]), 0.5)
            for _ in 0..<bin_duplicate / 2 {
                freqDomainValues += mean_mag;
            }
            for _ in 0..<bin_duplicate / 2 {
                freqDomainValues += mag_log;
            }
            //freqDomainValues += mag_log;
        }
        bufferCount *= bin_duplicate;
        
        
    }
    
    func fill_mag_log(i: Int) {
        vDSP.convertElements(of: h[i..<i + piece_len], to: &timeDomainBuffer)
        vDSP.multiply(timeDomainBuffer,
                      hannWindow,
                      result: &splitComplexRealInput[0..<piece_len])

        
        
        
        let splitComplexDFT = try? vDSP.DiscreteFourierTransform(
                                          previous: nil,
                                          count: sampleCount,
                                          direction: .forward,
                                          transformType: .complexComplex,
                                          ofType: Float.self);

        var splitComplexOutput = splitComplexDFT?.transform(real: splitComplexRealInput, imaginary: splitComplexImaginaryInput)

        let forwardOutput = DSPSplitComplex(
            realp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.real)),
            imagp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.imaginary)))

        vDSP.absolute(forwardOutput, result: &magnitudes)
        
        
        var idx: Int = start_idx
        //var idx: Int = 0;
        var idx_log: Int = 0
        // trim upper segments, should be 0...last_exp if not
        for cur_exp in 0...last_exp {
        //for cur_exp in 0..<last_exp {
            let forw = Int(pow(2, Double(cur_exp)))
            let backw = Int(pow(2, Double(last_exp - cur_exp)))
            var temp_idx = idx
            //while (temp_idx < idx + forw * zero_padding) {
            while (temp_idx < min(idx + forw * zero_padding, sampleCount / 2)) {
                let temp_val = magnitudes[temp_idx]
                vDSP.fill(&mag_log[idx_log..<idx_log + backw], with: temp_val)
                idx_log += backw
                temp_idx += 1
            }
            idx = temp_idx
        }
    }
    
    
    
}




//class Spectrogram {
//    
//    // magnitudes: each column of spectrogram
//    var magnitudes: [Float] = []
//    
//    // magnitudes in log scale
//    var mag_log: [Float] = []
//    
//    // for fourier transforms
//    var splitComplexRealInput: [Float] = []
//    var splitComplexImaginaryInput: [Float] = []
//    
//    // length of each piece of data put in fourier transform
//    var piece_len: Int = 0
//    
//    // actual length of magnitudes, take in account of zero_padding
//    var sampleCount: Int = 0
//    
//    // prune the bottom of the spectrogram to make it start at 10 hz
//    var start_idx: Int = 0
//    
//    // last exponential in making log-scale y-axis
//    var last_exp: Int = 0
//    
//    // hanning window applied to fourier transform
//    var hannWindow: [Float] = []
//    
//    // split data into bufferCount buffer and apply fourier transform to each buffer
//    var bufferCount: Int = 40
//    
//    
//    var timeDomainBuffer: [Float] = []
//    var freqDomainValues: [Float] = []
//    
//    let bin_duplicate: Int = 2
//    
//    // zero-padding of each column of spectrogram
//    var zero_padding: Int = 0
//    
//    // waveform curve values
//    var h: [Double] = []
//    
//    var len_log: Int = 0
//    
//    init(run_chirp: inout Run_Chirp) {
////        refresh(run_chirp: &testChirp)
//        let freqCount = run_chirp.freqCount()
//        
//        piece_len = Int(freqCount / bufferCount)
//        
//        let sc_no_padding = Int(pow(2, ceil(log2(Double(piece_len)))))
//        
//        last_exp = Int(log2(Double(sc_no_padding / 2))) - 1
//        
//        let len_log_no_padding = (last_exp + 1) * Int(pow(2, Double(last_exp)))
//        
//        zero_padding = max(Int(pow(2, floor(log2(9000 / Double(len_log_no_padding))))), 1)
//        
//        sampleCount = sc_no_padding * zero_padding
//        
//        splitComplexRealInput = [Float](repeating: 0, count: sampleCount)
//        splitComplexImaginaryInput = [Float](repeating: 0, count: sampleCount)
//        
//        magnitudes = [Float](repeating: 0, count: sampleCount)
//        
//        len_log = zero_padding * len_log_no_padding
//        
//        mag_log = [Float](repeating: 0, count: len_log)
//        
//        start_idx = Int(floor(Double(sampleCount) / (run_chirp.getFSamp() / 20)))
//        
//        timeDomainBuffer = [Float](repeating: 0, count: piece_len)
//        freqDomainValues.reserveCapacity(len_log * bufferCount * bin_duplicate)
//        
//        hannWindow = vDSP.window(ofType: Float.self,
//                                 usingSequence: .hanningDenormalized,
//                                 count: piece_len,
//                                 isHalfWindow: false)
//        
//        h = run_chirp.getH()
//    }
//    
//    func refresh(run_chirp: inout Run_Chirp) {
//        let freqCount = run_chirp.freqCount()
//        
//        piece_len = Int(freqCount / bufferCount)
//        
//        let sc_no_padding = Int(pow(2, ceil(log2(Double(piece_len)))))
//        
//        last_exp = Int(log2(Double(sc_no_padding / 2))) - 1
//        
//        let len_log_no_padding = (last_exp + 1) * Int(pow(2, Double(last_exp)))
//        
//        zero_padding = max(Int(pow(2, floor(log2(9000 / Double(len_log_no_padding))))), 1)
//        
//        sampleCount = sc_no_padding * zero_padding
//        
//        splitComplexRealInput = [Float](repeating: 0, count: sampleCount)
//        splitComplexImaginaryInput = [Float](repeating: 0, count: sampleCount)
//        
//        magnitudes = [Float](repeating: 0, count: sampleCount)
//        
//        len_log = zero_padding * len_log_no_padding
//        
//        mag_log = [Float](repeating: 0, count: len_log)
//        
//        start_idx = Int(floor(Double(sampleCount) / (run_chirp.getFSamp() / 20)))
//        
//        timeDomainBuffer = [Float](repeating: 0, count: piece_len)
//        freqDomainValues.reserveCapacity(len_log * bufferCount * bin_duplicate)
//        
//        hannWindow = vDSP.window(ofType: Float.self,
//                                 usingSequence: .hanningDenormalized,
//                                 count: piece_len,
//                                 isHalfWindow: false)
//        
//        h = run_chirp.getH()
//    }
//    
//    func genSpectrogram() -> UIImage {
//        fill_freqDomainValues()
//        
//        let maxFreqVal = vDSP.maximum(freqDomainValues)
//        let maxFloat = maxFreqVal * 1.2
//        let minFloat = 0 - maxFreqVal * 0.1
//        
//        let rgbImageFormat: vImage_CGImageFormat = {
//            guard let format = vImage_CGImageFormat(
//                    //bitsPerComponent: 8,
//                    //bitsPerPixel: 8 * 4,
//                    bitsPerComponent: 8,
//                    bitsPerPixel: 8 * 4,
//                    colorSpace: CGColorSpaceCreateDeviceRGB(),
//                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
//                    renderingIntent: .defaultIntent) else {
//                fatalError("Can't create image format.")
//            }
//            
//            return format
//        }()
//        
//        /// RGB vImage buffer that contains a vertical representation of the audio spectrogram.
//        var rgbImageBuffer: vImage_Buffer = {
//            guard let buffer = try? vImage_Buffer(
//                width: len_log,        //sampleCount / 2,
//                height: bufferCount,
//                bitsPerPixel: rgbImageFormat.bitsPerPixel) else {
//                fatalError("Unable to initialize image buffer.")
//            }
//            return buffer
//        }()
//
//        /// RGB vImage buffer that contains a horizontal representation of the audio spectrogram.
//        var rotatedImageBuffer: vImage_Buffer = {
//            guard let buffer = try? vImage_Buffer(
//                width: bufferCount,
//                height: len_log,       //sampleCount / 2,
//                bitsPerPixel: rgbImageFormat.bitsPerPixel)  else {
//                fatalError("Unable to initialize rotated image buffer.")
//            }
//            return buffer
//        }()
//        
//        //let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
//        //let minFloats: [Float] = [255, 0, 0, 0]
//        let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
//        let minFloats: [Float] = [255, minFloat, minFloat, minFloat]
//        
//        freqDomainValues.withUnsafeMutableBufferPointer {
//            var planarImageBuffer = vImage_Buffer(
//                data: $0.baseAddress!,
//                height: vImagePixelCount(bufferCount),
//                width: vImagePixelCount(len_log),  //sampleCount / 2),
//                rowBytes: (len_log) * MemoryLayout<Float>.stride)
//                //rowBytes: sampleCount / 2 * MemoryLayout<Float>.stride)
//            
//            vImageConvert_PlanarFToARGB8888(
//                &planarImageBuffer,
//                &planarImageBuffer,
//                &planarImageBuffer,
//                &planarImageBuffer,
//                &rgbImageBuffer,
//                maxFloats,
//                minFloats,
//                vImage_Flags(kvImageNoFlags))
//        }
//        
//        vImageTableLookUp_ARGB8888(
//            &rgbImageBuffer,
//            &rgbImageBuffer,
//            nil,
//            &redTable,
//            &greenTable,
//            &blueTable,
//            vImage_Flags(kvImageNoFlags))
//        
//        vImageRotate90_ARGB8888(
//            &rgbImageBuffer,
//            &rotatedImageBuffer,
//            UInt8(kRotate90DegreesCounterClockwise),
//            [UInt8()],
//            vImage_Flags(kvImageNoFlags))
//        
//        let result = try? rotatedImageBuffer.createCGImage(format: rgbImageFormat)
//        //let result = try? rgbImageBuffer.createCGImage(format: rgbImageFormat)
//        
//        
//        //let success = saveImage(image: UIImage(cgImage: result!))
//        //print(success)
//        return UIImage(cgImage: result!)
//    }
//    
//    func fill_freqDomainValues() {
//        fill_mag_log(i: 0)
//        
//        for _ in 0..<bin_duplicate {
//            freqDomainValues += mag_log
//        }
//        
//        for i in stride(from: piece_len, to: bufferCount * piece_len, by: piece_len) {
//
//            
//            fill_mag_log(i: i)
//
//            
//            
//            let mean_mag = vDSP.multiply(addition: (mag_log, freqDomainValues[freqDomainValues.count - len_log..<freqDomainValues.count]), 0.5)
//            for _ in 0..<bin_duplicate / 2 {
//                freqDomainValues += mean_mag;
//            }
//            for _ in 0..<bin_duplicate / 2 {
//                freqDomainValues += mag_log;
//            }
//            //freqDomainValues += mag_log;
//        }
//        bufferCount *= bin_duplicate;
//        
//        
//    }
//    
//    func fill_mag_log(i: Int) {
//        vDSP.convertElements(of: h[i..<i + piece_len], to: &timeDomainBuffer)
//        vDSP.multiply(timeDomainBuffer,
//                      hannWindow,
//                      result: &splitComplexRealInput[0..<piece_len])
//
//        
//        
//        
//        let splitComplexDFT = try? vDSP.DiscreteFourierTransform(
//                                          previous: nil,
//                                          count: sampleCount,
//                                          direction: .forward,
//                                          transformType: .complexComplex,
//                                          ofType: Float.self);
//
//        var splitComplexOutput = splitComplexDFT?.transform(real: splitComplexRealInput, imaginary: splitComplexImaginaryInput)
//
//        let forwardOutput = DSPSplitComplex(
//            realp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.real)),
//            imagp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.imaginary)))
//
//        vDSP.absolute(forwardOutput, result: &magnitudes)
//        
//        
//        var idx: Int = start_idx
//        //var idx: Int = 0;
//        var idx_log: Int = 0
//        // trim upper segments, should be 0...last_exp if not
//        for cur_exp in 0...last_exp {
//        //for cur_exp in 0..<last_exp {
//            let forw = Int(pow(2, Double(cur_exp)))
//            let backw = Int(pow(2, Double(last_exp - cur_exp)))
//            var temp_idx = idx
//            //while (temp_idx < idx + forw * zero_padding) {
//            while (temp_idx < min(idx + forw * zero_padding, sampleCount / 2)) {
//                let temp_val = magnitudes[temp_idx]
//                vDSP.fill(&mag_log[idx_log..<idx_log + backw], with: temp_val)
//                idx_log += backw
//                temp_idx += 1
//            }
//            idx = temp_idx
//        }
//    }
//    
//}



