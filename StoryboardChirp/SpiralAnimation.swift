//
//  SpiralAnimation.swift
//  StoryboardChirp
//
//  Created by Bolin Wu on 2/26/23.
//

import Foundation
import UIKit
import Accelerate
import Darwin
import SwiftUI
import Charts


extension Run_Chirp {
    
    func initSpiral() {
        let dx = 2.0 * halfwindow / Double(nrow)
        let x_ax = Array(stride(from: -halfwindow, through: halfwindow, by: dx))
        var x_grid = [[Double]](repeating: x_ax, count: x_ax.count).flatMap{ $0 }
        var y_grid = [Double](repeating: 0, count: x_grid.count)
        vDSP_mtransD(&x_grid, 1, &y_grid, 1, vDSP_Length(x_ax.count), vDSP_Length(x_ax.count))
        vDSP.reverse(&y_grid)
//        print(y_grid)
        let dist_grid = vForce.sqrt(vDSP.add(vDSP.square(x_grid), vDSP.square(y_grid)))
        
        tret_grid = vDSP.multiply(-1/c, dist_grid)
        print("tret_grid size: \(tret_grid.count)")
        
        // 2 * atan(y/x)
        arctan_2 = vDSP.multiply(2, vForce.atan2(x: x_grid, y: y_grid))
    }
    
    
    func genSpiralAnimation(speedX: Double) -> ([UIImage], Double) {
//        let nrow = 150
//        var heightD: [Double] = spiral_test()
        let timeToReachCorner:Double = t[0] + sqrt(2) * halfwindow / c
        var tstart: Double = timeToReachCorner
        var tend: Double = t[freq.count - 1]
        
        var imageList: [UIImage] = []
        
        let rgbImageFormat: vImage_CGImageFormat = {
            guard let format = vImage_CGImageFormat(
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
                width: nrow,
                height: nrow,
                bitsPerPixel: rgbImageFormat.bitsPerPixel) else {
                fatalError("Unable to initialize image buffer.")
            }
            return buffer
        }()
        
        // extend the animation until the spiral disappear
        tend += timeToReachCorner
        
        // only keep the last dur seconds
        var dur: Double = 10
        let originalDur = (tend - tstart) / speedX
        print("original duration: ", originalDur)
        
        // truncate time to have only last dur seconds
        if originalDur > dur {
            tstart = tend - dur * speedX
        }
        dur = min(dur, originalDur)
        
//        let ntime: Double = 800
//        let dtnow = (tend - tstart) / ntime
        let dtnow = 0.0006
        let ntime = (tend - tstart) / dtnow
        let timePerImage = dtnow / speedX
        
        
        print("tstart: \(tstart)")
        print("tend: \(tend)")
        print("dtnow: ", dtnow)
        print("ntime: ", ntime)
        
        for tnow in stride(from: tstart, through: tend, by: dtnow) {
            let heightD: [Double] = heightAt(tnow: tnow)
            if (Array(heightD[0..<20]).allSatisfy{$0 == 0.0}) {
                dur = (tnow - tstart) / speedX
                print(heightAt(tnow: tnow - dtnow)[0..<50])
                break
            }
            
    //        var hret: [Float] = [Float](repeating: 0, count: hretD.count)
            
    //        hret = vDSP.convertElements(of: hretD, to: &hret)
            var height = vDSP.doubleToFloat(heightD)
            
//            let maxFreqVal = vDSP.maximum(height)
//            let minFreqVal = vDSP.minimum(height)
//            let maxFreqVal = Float(max_h)
//            let minFreqVal = Float(min_h)
            let maxFreqVal = max(abs(Float(max_h)), abs(Float(min_h)))
            let minFreqVal = -maxFreqVal
            let maxFloat = maxFreqVal * 1.5
            let minFloat = minFreqVal * 0.6
            
            
            
            //let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
            //let minFloats: [Float] = [255, 0, 0, 0]
            let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
            let minFloats: [Float] = [255, minFloat, minFloat, minFloat]
            
            height.withUnsafeMutableBufferPointer {
                var planarImageBuffer = vImage_Buffer(
                    data: $0.baseAddress!,
                    height: vImagePixelCount(nrow),
                    width: vImagePixelCount(nrow),
                    rowBytes: (nrow) * MemoryLayout<Float>.stride)
                
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
            
            let result = try? rgbImageBuffer.createCGImage(format: rgbImageFormat)

            imageList.append(UIImage(cgImage: result!))
        }
//        for tidx in stride(from: tend - 10*dtnow, through: tend, by: dtnow) {
//            print(heightAt(tnow: tidx)[1...50])
//        }
//        print(heightAt(tnow: tend)[1...50])
        return (imageList, dur)
//        return UIImage.animatedImage(with: imageList, duration: dur)!

    }
        
    func heightAt(tnow: Double) -> [Double]{
        var tret = vDSP.add(tnow, tret_grid)
        
        vDSP.multiply(fsamp, tret, result: &tret)
        
//        var hret = [Double](repeating: 0, count: tret.count)
//
//        vDSP_vlintD(h,
//                    tret, vDSP_Stride(1),
//                    &hret, vDSP_Stride(1),
//                    vDSP_Length(tret.count),
//                    vDSP_Length(h.count))
        
        
        let timeToReachCorner:Double = t[0] + sqrt(2) * halfwindow / c
        
        var phiret = [Double](repeating: 0, count: tret.count)
        vDSP_vlintD(phi + [Double](repeating: 0, count: Int(timeToReachCorner * fsamp)),
                    tret, vDSP_Stride(1),
                    &phiret, vDSP_Stride(1),
                    vDSP_Length(tret.count),
                    vDSP_Length(phi.count))
        
        var ampret = [Double](repeating: 0, count: tret.count)
        vDSP_vlintD(amp + [Double](repeating: 0, count: Int(timeToReachCorner * fsamp)),
                    tret, vDSP_Stride(1),
                    &ampret, vDSP_Stride(1),
                    vDSP_Length(tret.count),
                    vDSP_Length(amp.count))
        
        let cos_phi = vForce.cos(vDSP.add(phiret, arctan_2))
        
        let height = vDSP.multiply(ampret, cos_phi)

        return height
    }
    
    func genSpiral() -> UIImage {
//        let nrow = 150
//        var heightD: [Double] = spiral_test()
        
        let tstart = t[0] + sqrt(2) * halfwindow / c
        
//        var imageList: [UIImage] = []
        
        let rgbImageFormat: vImage_CGImageFormat = {
            guard let format = vImage_CGImageFormat(
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
                width: nrow,        //sampleCount / 2,
                height: nrow,
                bitsPerPixel: rgbImageFormat.bitsPerPixel) else {
                fatalError("Unable to initialize image buffer.")
            }
            return buffer
        }()
        
        let tnow = tstart

        let heightD: [Double] = heightAt(tnow: tnow)

//        var hret: [Float] = [Float](repeating: 0, count: hretD.count)

//        hret = vDSP.convertElements(of: hretD, to: &hret)
        var height = vDSP.doubleToFloat(heightD)

        let maxFreqVal = vDSP.maximum(height)
        let minFreqVal = vDSP.minimum(height)
        let maxFloat = maxFreqVal * 1.5
        let minFloat = minFreqVal



        //let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
        //let minFloats: [Float] = [255, 0, 0, 0]
        let maxFloats: [Float] = [255, maxFloat, maxFloat, maxFloat]
        let minFloats: [Float] = [255, minFloat, minFloat, minFloat]

        height.withUnsafeMutableBufferPointer {
            var planarImageBuffer = vImage_Buffer(
                data: $0.baseAddress!,
                height: vImagePixelCount(nrow),
                width: vImagePixelCount(nrow),
                rowBytes: (nrow) * MemoryLayout<Float>.stride)

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

        let result = try? rgbImageBuffer.createCGImage(format: rgbImageFormat)
        //let result = try? rgbImageBuffer.createCGImage(format: rgbImageFormat)


        //let success = saveImage(image: UIImage(cgImage: result!))
        //print(success)
        return UIImage(cgImage: result!)
    }
    
    func spiral_test() -> [Double] {
        
        let tstart = t[0] + sqrt(2) * halfwindow / c
        
        let tnow = tstart
        var tret = vDSP.add(tnow, tret_grid)
        
        vDSP.multiply(fsamp, tret, result: &tret)
        
//        var hret = [Double](repeating: 0, count: tret.count)
//
//        vDSP_vlintD(h,
//                    tret, vDSP_Stride(1),
//                    &hret, vDSP_Stride(1),
//                    vDSP_Length(tret.count),
//                    vDSP_Length(h.count))
        
        

        
        var phiret = [Double](repeating: 0, count: tret.count)
        vDSP_vlintD(phi,
                    tret, vDSP_Stride(1),
                    &phiret, vDSP_Stride(1),
                    vDSP_Length(tret.count),
                    vDSP_Length(phi.count))
        
        var ampret = [Double](repeating: 0, count: tret.count)
        vDSP_vlintD(amp,
                    tret, vDSP_Stride(1),
                    &ampret, vDSP_Stride(1),
                    vDSP_Length(tret.count),
                    vDSP_Length(amp.count))
        
        let cos_phi = vForce.cos(vDSP.add(phiret, arctan_2))
        
        let height = vDSP.multiply(ampret, cos_phi)

        return height
        
        
    }
    
}
