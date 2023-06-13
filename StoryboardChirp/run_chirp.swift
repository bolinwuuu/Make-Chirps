//
//  run_chirp.swift
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
import AVFoundation




struct Coords {
    var x_val: Double
    var y_val: Double
    
    init(x_in: Double, y_in: Double) {
        self.x_val = x_in;
        self.y_val = y_in;
    }
}

// For interpolation of frequency
struct Point {
    let x: Double
    let y: Double
}

class Run_Chirp {
    
    // two input masses
    var m1: Double = 20
    var m2: Double = 20
    
    // radii of stars
    var r1: Double = 0
    var r2: Double = 0
    
    // number of samples, which is the size of the vectors below, t, freq, h
    var sampleN: Double = 0
    
    // time vector, on the x axis
    var t: [Double] = []
    
    // frequency vector, for runMode 3
    var freq: [Double] = []
    
    //var freqw: [Double]
    
    // waveform vector, for runMode 2
    var h: [Double] = []
    
    var amp: [Double] = []
    var phi: [Double] = []
    
    
//    // vector of semi-major axis, for animation
//    var a: [Double]
    
    // max value of h
    var max_h: Double = 0
    
    // sample frequency
    var fsamp: Double = 0
    
    var dt: Double = 0
    
    // last sample before triming
    var lastSample: Double = 0
    
    // time remaining to coalescence from entering band
    var tau: Double = 0
    
    // Frequency coefficient
    var fcoeff: Double = 0
    
    var ftouch: Double = 0
    
    // down sample factor
    var downSample: Double = 0
    
    // Physical constants

    let g:Double = 6.67e-11
    let c:Double = 2.998e8
    let pc:Double = 3.086e16
    let msun:Double = 2.0e30
    
    
    // ----------------------------------------------------------
    // ----------------------------------------------------------
    //              variables for spectrogram

    
    // magnitudes: each column of spectrogram
    var magnitudes: [Float] = []
    
    // magnitudes in log scale
    var mag_log: [Float] = []
    
    // for fourier transforms
    var splitComplexRealInput: [Float] = []
    var splitComplexImaginaryInput: [Float] = []
    
    // length of each piece of data put in fourier transform
    var piece_len: Int = 0
    
    // actual length of magnitudes, take in account of zero_padding
    var sampleCount: Int = 0
    
    // prune the bottom of the spectrogram to make it start at 10 hz
    var start_idx: Int = 0
    
    // last exponential in making log-scale y-axis
    var last_exp: Int = 0
    
    // hanning window applied to fourier transform
    var hannWindow: [Float] = []
    
    // split data into bufferCount buffer and apply fourier transform to each buffer
    var bufferCount: Int = 40
    
    
    var timeDomainBuffer: [Float] = []
    var freqDomainValues: [Float] = []
    
    let bin_duplicate: Int = 2
    
    // zero-padding of each column of spectrogram
    var zero_padding: Int = 0
    
    var len_log: Int = 0
    

    //          end variables for spectrogram
    // ----------------------------------------------------------
    // ----------------------------------------------------------
    
    
    // ----------------------------------------------------------
    // ----------------------------------------------------------
    //              variables for spiral animation

    
    // number of rows & cols of animation images (nrow * nrow)
    let nrow: Int = 150
    
    // dist of half of the window
    let halfwindow: Double = 1e7
    
    // flatten matrix of retarded time
    var tret_grid: [Double] = []
    
    // flatten matrix of 2 * arctan(y/x)
    var arctan_2: [Double] = []
    

    //          end variables for spiral animation
    // ----------------------------------------------------------
    // ----------------------------------------------------------
    
    
    // initializer, all computations for the vectors above
    init(mass1: Double, mass2: Double) {
        changeMasses(mass1: mass1, mass2: mass2)
    } // initializer
    
    func changeMasses(mass1: Double, mass2: Double) {
        m1 = mass1
        m2 = mass2

        // Implied chirp mass (governs frequency and amplitude evolution)
        // (PPNP text right after Eqn 74)
          
        let mchirp:Double = pow((m1*m2),(3/5))/pow((m1+m2),(1/5));


        
        // Compute Schwarzchild radii of stars

        r1 = 2 * g * m1 * msun / pow(c, 2);
        r2 = 2 * g * m2 * msun / pow(c, 2);

        // Frequency coefficient
        // (Based on PPNP Eqn 73)

        fcoeff = (1/(8*Double.pi)) * pow(pow(5, 3), 1/8) * pow(pow(c, 3) / (g*mchirp*msun), 5/8)

        // Amplitude coefficient (assume source at 15 Mpc)
        // (Based on PPNP Eqn 74)

        let rMpc:Double = 15
        let r = rMpc * 1e6 * pc
        let hcoeff = (1/r) * pow(5*pow(g*mchirp*msun/pow(c, 2), 5)/c, 1/4)

        // Amplitude rescaling parameter
        let hscale:Double = 1e21

        // frequency (Hz) when signal enters detector band
        let fbandlo:Double = 30

        // Compute time remaining to coalescence from entering band
        // (Based on PPNP Eqn 73)

        tau = pow(fcoeff/fbandlo, 8/3)

        // Debugging summary

        print("Starting chirp simulation with M1, M2, Mchirp = ", m1, " ", m2, " ", mchirp, " (Msun)")
        print("--> Schwarzchild radii = ", r1, " ", r2, "m")
        print("Distance to source r = ", rMpc, " Mpc")
        print("Detection band low frequency = ", fbandlo, "Hz\n--> Time to coalescence = ", tau, " s\n")

        // Sampling rate (Hz) - fixed at 48 kHz for mp4 output
        
        downSample = 10
        fsamp = 48000 / downSample
        dt = 1/fsamp

        // Length of time to simulate (round up to nearest tenth of an integer second and add a tenth)

        let upperT = ceil(10*tau)/10 + 0.1

        // Create time sample container

        sampleN = floor(fsamp*upperT)

        t = Array(stride(from: 0, through: sampleN-1, by: 1))
        t = vDSP.multiply(dt, t)

        // Determine frequency (and then time) when Schwarzchild radii touch
        // (Use Kepler's 3rd law)
        // (Double orbital frequency to get GW frequency)

        ftouch = 2 * (1/(2*Double.pi)) * pow(g*(m1+m2)*msun/pow(r1+r2,3), 1/2)
        let tautouch = pow(fcoeff/ftouch, 8/3)
        print("GW frequency when Schwarzchild radii touch: ", ftouch, " Hz\n--> Occurs ", tautouch, " seconds before point-mass coalescence\n")
        
        // Create frequency value vs time (up to last time sample before point-mass coalescence)
        // (Based on PPNP Eqn 73)
        
        //var minusdt = -dt;
        //var vzero:Double = 0;
        //var iTau:Double = floor(tau / dt);

        
        lastSample = floor((pow(ftouch / fcoeff, -8/3) - tau) / -dt)
        
        let maxFreq:Double = pow(-lastSample * dt + tau, -3/8) * fcoeff
        
        var freq1 = Array(stride(from: 0, through: lastSample, by: 1))
        
        
        vDSP.multiply(-dt, freq1, result: &freq1)
        vDSP.add(tau, freq1, result: &freq1)

        
        //var exp = [Double](repeating: -3/8, count: freq1.count);
        
        
        freq = [Double](repeating: maxFreq, count: min(9 * freq1.count / 8, Int(sampleN)))
        //var freq_temp = vForce.pow(bases: freq1, exponents: exp);
        var freq_temp = freq1.map { (pow($0, -3/8)) }
        vDSP.multiply(fcoeff, freq_temp, result: &freq_temp)
        cblas_dcopy(Int32(freq_temp.count), &freq_temp, 1, &freq, 1)
        
//        var freq = vForce.pow(bases: freq1, exponents: exp);
//        vDSP.multiply(fcoeff, freq, result: &freq);
//        let freq2 = [Double](repeating: maxFreq, count: min(Int(freq1.count / 8), Int(sampleN - lastSample) - 1));
//        freq += freq2;
        

        
        //Create amplitude value vs time (up to last time sample before touch)
        // (Based on PPNP Eqn 74)
   
        //vDSP.fill(&exp, with: -1/4);

        
        amp = [Double](repeating: 0, count: freq.count)
        //vForce.pow(bases: freq1, exponents: exp, result: &freq1);
        freq1 = freq1.map { (pow($0, -1/4)) }
        vDSP.multiply(hcoeff * hscale, freq1, result: &freq1)
        cblas_dcopy(Int32(freq1.count), &freq1, 1, &amp, 1)
        
//        var amp = [Double](repeating: 0, count: freq.count);
//        var amp1 = vForce.pow(bases: freq1, exponents: exp);
//        vDSP.multiply(hcoeff * hscale, amp1, result: &amp1);
//        cblas_dcopy(Int32(amp1.count), &amp1, 1, &amp, 1)
         
        
        // Generate strain signal in time domain
        
        
        phi = [Double](repeating: 0, count: freq.count)
        // Cumulative sum of freq
        phi[0] = freq[0]
        for index in 1...freq.count - 1 {
            phi[index] = phi[index - 1] + freq[index]
        }
        vDSP.multiply(2 * Double.pi * dt, phi, result: &phi)

        
        h = vDSP.multiply(amp, vForce.sin(phi))
        
        
        

        //Adjustments for Ringdown ---------------------------
        
        // Wavelength
        var quasi = computeFinalOrbitalAngularMomentum(M1: m1, M2: m2);
        h = appendRingDownandNormalWaveForm(h: h, quasi: quasi)
        //t = [];
        var tmax = Double(h.count) * dt
        t = stride(from: 0.0, through: tmax, by: dt).map { $0 }

        
        max_h = vDSP.maximum(h)
        
        // Frequency Ringdown
        
        var freq_last_index = freq.count - 1;
        var last_value_freq = freq[freq_last_index]
        var i = freq_last_index;
        
        //Making frequency graph same length as wavelength
        
        while i < h.count {
            freq.append(last_value_freq)
            i = i + 1;
        }
        
        //Interpolation
        var qnmfreq = returnQNMFreq(M1: m1, M2: m2)[0]
        
        //starting index for interpolation
        freq_last_index = freq.firstIndex(of: last_value_freq)!;
        
        //difference between last evolving frequency and end of frequency array
        var difference = (freq.count - 1) - freq_last_index;
        var half_difference = Int(ceil(Double(difference) / 2));
        
        
        
      //  for i in freq_last_index...(freq.count - 1) {
      //      freq[i] = 0;
    //    }
        
        //THIS is likely causing the spike.
        freq[half_difference + freq_last_index] = qnmfreq
        
        for i in (half_difference + freq_last_index)...(freq.count - 1){
            freq[i] = qnmfreq
        }
        
        
        
        // Exponential decay of frequency
        // Constant of decay mathces amplitude
        // freq = B + (A-B) * exp
        
        
        var startIndex = freq_last_index
        var endIndex = freq.count-1
        var differenceIndexes = endIndex - startIndex

        let qnmtau = returnQNMFreq(M1: m1, M2: m2)[1]
        var sigmatime = qnmtau
        gaussianDecay(arr: &freq, startIndex: startIndex, qnmfreq: qnmfreq, sigmatime: sigmatime)
 //   applyExponentialDecay(arr: &freq, startIndex: startIndex, qnmfreq: qnmfreq)
        
        
     // interpolateArray(frequencyArray: &freq, mergerIndex: startIndex, stableIndex: (startndex + half_difference)
     // freq = smoothArray;
        
        
        if freq.count < h.count {
            let difference = h.count - freq.count
            h = h.dropLast(difference)
        }
        else if h.count < freq.count {
            let difference = freq.count - h.count
            freq = freq.dropLast(difference)
        }
        
        
        //END Adjustments for Ringdown --------------------------------
        print("chirp mass",mchirp)
        print("qnm_tau: ",qnmtau)
        print("qnm_freq: ", qnmfreq)
        print("merger freq: ", last_value_freq)
        print("t size: ", t.count)
        print("amp size: ", amp.count)
        print("phi size: ", phi.count)
        print("freq size: ", freq.count)
        print("h size: ",h.count)
    }
    
    
//    // currently runMode 2 and 3
//    func run_mode(runMode: Int) -> [Coords] {
//        if (runMode == 2) {
//            return run_mode_2();
//        }
//        else if (runMode == 3) {
//            return run_mode_3();
//        }
//        else {
//            let ret = [Coords(x_in: 0, y_in: 0)];
//            return ret;
//        }
//    }
    
    // Cubic Hermite Spline Interpolation
    
    func applyExponentialDecay(arr: inout [Double], startIndex: Int, qnmfreq: Double) {
        let x_1 = startIndex
        let x_2 = arr.count-1
        let a: Double = arr[startIndex] // - qnmfreq // starting value minus asymptotic value
        let b: Double = -log(0.5) / Double(x_2 - x_1) // rate of decay
        let c: Double = qnmfreq // asymptotic value

        for i in x_1...x_2 {
            let x = i-x_1
            arr[i] = c + (a-c) * exp(-b * Double(x))
        }
    }
    
    func gaussianDecay(arr: inout [Double], startIndex: Int, qnmfreq: Double, sigmatime: Double) {
        
        let x_1 = startIndex
        let x_2 = arr.count-1
        
        let initial_slope = ( arr[x_1] - arr[x_1-1])
        
        var next_slope = initial_slope / 10.0 // was 4
        var j = x_1 + 1
        
        while next_slope > 0.01 { //was 0.1
            arr[j] = arr[j-1] + next_slope
            next_slope = next_slope / 10.0 // was 4
            j = j + 1
        } // at the end, the value at index j will have not been altered yet.
        
        // let sigma = 35; // should scale with ringdown exponential decay sigma, that value or less
        var sigma = (sigmatime * 4800.0) / 3.0
        let minVal = qnmfreq;
        let mu = j-1
        let maxVal = arr[j-1]
        
        for i in (j-1)...x_2 {
            let x = i
            
            arr[i] = ( Double(maxVal - minVal) * exp( Double(-(x - mu) * (x - mu)) / Double(2 * sigma * sigma))) + minVal
            
         //   (arr[j-1] - qnmfreq) * exp (-(x-(j-1)) / (2 * (pow(0.65, 2))) )
        }
        
    }
        func applyDecayingBellCurveAtIndex(arr: inout [Double], peakIndex: Int, sigma: Double, maxVal: Double, minVal: Double) {
            guard peakIndex >= 0 && peakIndex < arr.count else {
                print("Invalid peakIndex")
                return
            }
            
            let mu = arr[peakIndex]
            
            for i in 0..<arr.count {
                let x = arr[i]
                if x < mu {
                    arr[i] = maxVal
                } else {
                    arr[i] = ((maxVal - minVal) * exp(-(x - mu) * (x - mu) / (2 * sigma * sigma))) + minVal
                }
            }
        }
        
        

    
    func interpolateFrequency(mergerIndex: Int, stableIndex: Int, mergerFrequency: Double, stableFrequency: Double, index: Int) -> Double {
        let lambda = -log((stableFrequency - mergerFrequency) / mergerFrequency) / Double(stableIndex - mergerIndex)
        let frequency = mergerFrequency * exp(-lambda * Double(index - mergerIndex)) + stableFrequency
        return frequency
    }

    func interpolateArray(frequencyArray: inout [Double], mergerIndex: Int, stableIndex: Int) {
        let mergerFrequency = frequencyArray[mergerIndex]
        let stableFrequency = frequencyArray[stableIndex]
        for i in mergerIndex...stableIndex {
            frequencyArray[i] = interpolateFrequency(mergerIndex: mergerIndex, stableIndex: stableIndex, mergerFrequency: mergerFrequency, stableFrequency: stableFrequency, index: i)
        }
    }

    func cubicHermiteSplineInterpolation(p0: Point, p1: Point, m0: Double, m1: Double, t: Double) -> Double {
        let t2 = t * t
        let t3 = t2 * t
        
        let h00 = 2 * t3 - 3 * t2 + 1
        let h10 = t3 - 2 * t2 + t
        let h01 = -2 * t3 + 3 * t2
        let h11 = t3 - t2
        
        return h00 * p0.y + h10 * m0 + h01 * p1.y + h11 * m1
    }

    func createSmoothArray(inputArray: [Double], numPoints: Int, startIndex: Int, endIndex: Int) -> [Double] {
        var smoothArray = inputArray
        let n = inputArray.count
        
        if startIndex >= endIndex || endIndex >= n {
            return inputArray
        }
        
        let p0 = Point(x: Double(startIndex), y: inputArray[startIndex])
        let p1 = Point(x: Double(endIndex), y: inputArray[endIndex])
        
        let m0: Double
        if startIndex == 0 {
            m0 = 0
        } else {
            m0 = (inputArray[startIndex + 1] - inputArray[startIndex - 1]) / (2)
        }
        
        let m1: Double
        if endIndex == n - 1 {
            m1 = 0
        } else {
            m1 = (inputArray[endIndex + 1] - inputArray[endIndex - 1]) / (2)
        }
        
        for j in 0...numPoints {
            let t = Double(j) / Double(numPoints)
            let interpolatedValue = cubicHermiteSplineInterpolation(p0: p0, p1: p1, m0: m0, m1: m1, t: t)
            smoothArray[startIndex + j] = interpolatedValue
        }

        return smoothArray
    }

    
    func genWaveform() -> [Coords] {
        var cd = [Coords](repeating: Coords(x_in: 0, y_in: 0), count: self.h.count)
        // wsa self.freq.count, changed to self.h.count
        
        var idx = 0;
        while (idx < cd.count) {
            cd[idx].x_val = self.t[idx]
            cd[idx].y_val = self.h[idx]
            idx += 1;
        }
        
        return cd;
    }
    
    func waveformDataEntries() -> [ChartDataEntry] {
        var cd = [ChartDataEntry]()
        
        for idx in 0..<self.h.count {
            cd.append(ChartDataEntry(x: self.t[idx], y: self.h[idx]))
            
//            print(x[idx], y[idx])
        }
        return cd
    }
    
    func genFreqCurve() -> [Coords] {
        var cd = [Coords](repeating: Coords(x_in: 0, y_in: 0), count: self.freq.count)
        var idx = 0
        while (idx < cd.count) {
            cd[idx].x_val = self.t[idx]
            cd[idx].y_val = self.freq[idx]
            idx += 1
        }
        return cd;
    }
    
    func freqDataEntries() -> [ChartDataEntry] {
        var cd = [ChartDataEntry]()
        
        for idx in 0..<self.h.count {
            cd.append(ChartDataEntry(x: self.t[idx], y: self.freq[idx]))
            
//            print(x[idx], y[idx])
        }
        return cd
    }
    

    func max_time() -> Double {
        return t[t.count - 1]
    }
    
    func freqCount() -> Int {
        return freq.count
    }
    
    func getFSamp() -> Double {
        return fsamp
    }
    
    func getH() -> [Double] {
        return self.h
    }
    
    func empty_data() -> [Coords] {
        return [Coords](repeating: Coords(x_in: 0, y_in: 10), count: 0)
    }
    
    func yaxis_scale() -> Double {
        return pow(10, ceil(log10(vDSP.maximum(freq))))
    }
    
    func xaxis_scale() -> Double {
        return t[freq.count - 1]
    }
    
    func getM1() -> Double {
        return m1
    }
    
    func getM2() -> Double {
        return m2
    }
    
    func getChirpMass() -> Double {
        return (pow((m1*m2),(3/5))/pow((m1+m2),(1/5)))
    }
    
    func getR1() -> Double {
        return r1
    }
    
    func getR2() -> Double {
        return r2
    }
    
//    func semiMajorAxis() -> [Double] {
//        return a
//    }
    func getFreq() -> [Double] {
        return freq
    }
    
    func getSampleN() -> Double {
        return sampleN
    }
    
    func getLastSample() -> Double {
        return lastSample
    }
    
    func getDT() -> Double {
        return 1 / fsamp
    }
    
    func extendedFreq() -> Double {
 
        let dt_no_DS = dt / downSample
        let lastSamp_no_DS = floor((pow(ftouch / fcoeff, -8/3) - tau) / -dt_no_DS)
        let temp = -lastSamp_no_DS * dt_no_DS + tau
        let lastFreq = (temp > 0) ? pow(temp, -3/8) * fcoeff : freq[Int(lastSample)]
//        print("sampleN: ", sampleN)
//        print("lastSample: ", lastSample)
//        print("lastSample no downSample: ", lastSamp_no_DS)
//        print("lastFreq: ", lastFreq)
//        print("freq[lastSample]: ", freq[Int(lastSample)])
//        print("temp: ", temp)

        return lastFreq
    }
    
    func saveWav1(_ buf: [[Float]]) -> URL {
       
        // The exponential decay would have to happen here
        /* % Apply sigmoid taper to end of waveform
         
         halfperiod_end = 0.01;
         twindow_end = transpose([0:1/fsamp:halfperiod_end]);
         envelope_end = 0.5 + 0.5*cos(pi/halfperiod_end*twindow_end);
         for i = 1:min(length(twindow_end),N-lastsample);
            haudio(lastsample+i) = envelope_end(i)*abs(hmax)*sin(phi(lastsample+i));
         end*/
        let halfperiod_end = 0.01;
        var maxwavelength = buf[0].max();
     
        
        
        // Putting Floats into AVAudioPCMBuffer Format
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 2, interleaved: false/*was false*/)
        let pcmBuf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(buf[0].count))
            memcpy(pcmBuf?.floatChannelData?[0], buf[0], 4 * buf[0].count)
            memcpy(pcmBuf?.floatChannelData?[1], buf[1], 4 * buf[1].count)
            pcmBuf?.frameLength = UInt32(buf[0].count)
            
  
        // Deleting all files currently in temp directory in order to reduce clutter
               let fileManager = FileManager.default
               let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
               let fileEnum = fileManager.enumerator(at: tempDirURL, includingPropertiesForKeys: nil)!
        for case let tempfilesUrl as URL in fileEnum {
            do{
                try fileManager.removeItem(at: tempfilesUrl)
            } catch {
                print("Error deleting files")
            }
        }
   
        //Create the .wav file from the PCMBuffer and save with random string name
                let wave_filename = ProcessInfo().globallyUniqueString;
                let fileURL = tempDirURL.appendingPathComponent(wave_filename + ".wav")
                print(fileURL.path)
                let audioFile = try! AVAudioFile(forWriting: fileURL, settings: format!.settings)
                try! audioFile.write(from: pcmBuf!)
                
                
                
           //Return the URL to the temporary .wav file that was created, to be played in view controller.
                return fileURL;
             
    }
    
    //Function to convert the array h of doubles into an array of floats to be compatible with AVAudio Fctns.
    func make_h_float(h: [Double]) -> [Float] {
        var index = 0
        var h_flt: [Float] = []
        while (index < h.count) {
            h_flt.append(Float(h[index]))
            index += 1
        }
        return h_flt
    }
    
    //Function to return an array of double values that model the ringdown waveform
    
    func generateSigmoidLogicCurveFrequency(final_freq: Double, starting_freq: Double) -> [Double] {
        
        
        
        return [1.0]
    }
    
    
    func computeFinalOrbitalAngularMomentum(M1: Double, M2: Double) -> [Double] {
         // Physical constants
         let G = 6.67e-11
         let c = 2.998e8
         let Msun = 2.0e30
         let factor = (G * Msun / pow(c, 3))
         
         // Masses of initial stars (solar mass units)
         //let M1 = 30.0
         //let M2 = 30.0
         
         // Compute final black hole mass (neglecting ~5% GW energy loss) and nu parameter
         let Mfinal = M1 + M2
         let nu = M1 * M2 / pow(Mfinal, 2)
         
         print("Starting with M1=\(M1), M2=\(M2) --> Mfinal=\(Mfinal) and nu=\(nu)")
         
         // Starting guess for af
         var af = nu * 0.66 / 0.25
         var aflast = 0.0
         
         // Iteratively improve estimate (assume prograde orbit for risco)
         var niter = 0
         
         while abs(af - aflast) > 0.00001 && niter <= 50 {
             aflast = af
             niter += 1
             let Z1 = 1 + pow((1 - pow(af, 2)), 1.0 / 3.0) * (pow((1 + af), 1.0 / 3.0) + pow((1 - af), 1.0 / 3.0))
             let Z2 = sqrt(3 * pow(af, 2) + pow(Z1, 2))
             let risco = 3 + Z2 - sqrt((3 - Z1) * (3 + Z1 + 2 * Z2))
             let Lorb = nu * (pow(risco, 2) - 2 * af * sqrt(risco) + pow(af, 2)) / pow(risco, 0.75) / (pow(risco, 1.5) - 3 * sqrt(risco) + 2 * af).squareRoot()
             af = Lorb
             print("niter=\(niter): af=\(aflast) gives Z1=\(Z1), Z2=\(Z2), risco=\(risco) and new af=\(af)")
             af = Lorb
         }
         
         // Values for dominant (m=2) mode column in Andersson table 17.1:
         let af_table = [0.0, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 0.99]
         let omega_real_table = [0.37367, 0.38702, 0.40215, 0.41953, 0.43984, 0.46412, 0.49405, 0.53260, 0.58602, 0.67163, 0.87086]
         let omega_imag_table = [0.08896, 0.08871, 0.08831, 0.08773, 0.08688, 0.08564, 0.08377, 0.08079, 0.07563, 0.06486, 0.02951]
         
         let omega_real = interpolate(af_table, omega_real_table, af)
         let omega_imag = interpolate(af_table, omega_imag_table, af)
         
         let QNM_freq = omega_real / (2 * Double.pi) / (factor * Mfinal)
         let QNM_tau = factor * Mfinal / omega_imag
         
         let R1 = (2 * G * M1 * Msun / pow(c, 2))
         let R2 = (2 * G * M2 * Msun / pow(c, 2))
         let ftouch = 2 * (1 / (2 * Double.pi)) * pow((G * (M1 + M2) * Msun / pow((R1 + R2), 3)), 1 / 2)
         
         print("Interpolated real/imag omega values: \(omega_real) -\(omega_imag) i\n --> QNM freq = \(QNM_freq) Hz, tau = \(QNM_tau) s (merger orbital freq = \(ftouch) Hz)")
        
        
        var tmax = 5 * QNM_tau;
        var dt: Double
        dt = 10.0 / 48000.0 ;
        var t = stride(from: 0.0, through: tmax, by: dt).map { $0 }
        
        var quasi: [Double] = []
        
        
        
        
        for i in 0...(t.count-1) {
            quasi.append(cos(2 * Double.pi * QNM_freq * t[i])  * exp(-t[i] / QNM_tau) )
        }
        
        
        return quasi; //pl
     }
    
    
    func returnQNMFreq(M1: Double, M2: Double) -> [Double]   {
        // Physical constants
        let G = 6.67e-11
        let c = 2.998e8
        let Msun = 2.0e30
        let factor = (G * Msun / pow(c, 3))
        
        // Masses of initial stars (solar mass units)
        //let M1 = 30.0
        //let M2 = 30.0
        
        // Compute final black hole mass (neglecting ~5% GW energy loss) and nu parameter
        let Mfinal = M1 + M2
        let nu = M1 * M2 / pow(Mfinal, 2)
        
        print("Starting with M1=\(M1), M2=\(M2) --> Mfinal=\(Mfinal) and nu=\(nu)")
        
        // Starting guess for af
        var af = nu * 0.66 / 0.25
        var aflast = 0.0
        
        // Iteratively improve estimate (assume prograde orbit for risco)
        var niter = 0
        
        while abs(af - aflast) > 0.00001 && niter <= 50 {
            aflast = af
            niter += 1
            let Z1 = 1 + pow((1 - pow(af, 2)), 1.0 / 3.0) * (pow((1 + af), 1.0 / 3.0) + pow((1 - af), 1.0 / 3.0))
            let Z2 = sqrt(3 * pow(af, 2) + pow(Z1, 2))
            let risco = 3 + Z2 - sqrt((3 - Z1) * (3 + Z1 + 2 * Z2))
            let Lorb = nu * (pow(risco, 2) - 2 * af * sqrt(risco) + pow(af, 2)) / pow(risco, 0.75) / (pow(risco, 1.5) - 3 * sqrt(risco) + 2 * af).squareRoot()
            af = Lorb
            print("niter=\(niter): af=\(aflast) gives Z1=\(Z1), Z2=\(Z2), risco=\(risco) and new af=\(af)")
            af = Lorb
        }
        
        // Values for dominant (m=2) mode column in Andersson table 17.1:
        let af_table = [0.0, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 0.99]
        let omega_real_table = [0.37367, 0.38702, 0.40215, 0.41953, 0.43984, 0.46412, 0.49405, 0.53260, 0.58602, 0.67163, 0.87086]
        let omega_imag_table = [0.08896, 0.08871, 0.08831, 0.08773, 0.08688, 0.08564, 0.08377, 0.08079, 0.07563, 0.06486, 0.02951]
        
        let omega_real = interpolate(af_table, omega_real_table, af)
        let omega_imag = interpolate(af_table, omega_imag_table, af)
        
        let QNM_freq = omega_real / (2 * Double.pi) / (factor * Mfinal)
        let QNM_tau = factor * Mfinal / omega_imag
        
        let R1 = (2 * G * M1 * Msun / pow(c, 2))
        let R2 = (2 * G * M2 * Msun / pow(c, 2))
        let ftouch = 2 * (1 / (2 * Double.pi)) * pow((G * (M1 + M2) * Msun / pow((R1 + R2), 3)), 1 / 2)
        
        print("Interpolated real/imag omega values: \(omega_real) -\(omega_imag) i\n --> QNM freq = \(QNM_freq) Hz, tau = \(QNM_tau) s (merger orbital freq = \(ftouch) Hz)")
        
        
        var tmax = 5 * QNM_tau;
        var dt: Double
        dt = 10.0 / 48000.0 ;
        var t = stride(from: 0.0, through: tmax, by: dt).map { $0 }
        
        return [QNM_freq,QNM_tau];
    }
        
    
    // Function to find the last sample of waveform and append the ringdown to it with a scalar
    func appendRingDownandNormalWaveForm(h: [Double], quasi: [Double]) -> [Double] {
        
        
        var maxindex: Int = h.enumerated().max(by: { abs($0.element) < abs($1.element)})!.offset
        
        var scalarForRingdown = h[maxindex];
        
        var quasi: [Double] = quasi;
            
        for i in 0...(quasi.count - 1){
            quasi[i] = scalarForRingdown * quasi[i];
        }
        
        //find index of element that is closest to one
        var closestIndex: Int?
        
        if maxindex < h.count - 1 {
            closestIndex = h.enumerated().filter({$0.offset > maxindex})
                .min(by: { abs($0.element - 1) < abs($1.element - 1) })?.offset
        }
        //identify time of coalescence, take last data sample before then
        
        let closestValuetoOne = h[closestIndex!];
        
        var conjoinedArray: [Double] = [];
        
        for i in 0...maxindex {
            conjoinedArray.append(h[i])
        }
        
        for i in 0...(quasi.count-1){
            conjoinedArray.append(quasi[i])
        }
        
        
        
        
        return conjoinedArray;
        
    }
     
     func interpolate(_ x: [Double], _ y: [Double], _ xi: Double) -> Double {
         guard let index = x.firstIndex(where: { $0 >= xi }) else { return y.last! }
         if index == 0 { return y.first! }
         
         let x0 = x[index - 1]
         let x1 = x[index]
         let y0 = y[index - 1]
         let y1 = y[index]
         
         return y0 + (y1 - y0) * (xi - x0) / (x1 - x0)
     }
    
 }

    


var testChirp = Run_Chirp(mass1: 20, mass2: 30)

var waveData = testChirp.genWaveform()

var freqData = testChirp.genFreqCurve()

//let spectUIIm = testChirp.genSpectrogram()

var emptyData = testChirp.empty_data()






/*
func saveImage(image: UIImage) -> Bool {
    guard let data = image.pngData() else {
        return false
    }
    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
        return false
    }
    //print(directory);
    do {
        try data.write(to: directory.appendingPathComponent("spectrogram.png")!)
        return true
    } catch {
        print(error.localizedDescription)
        return false
    }
}



func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}*/


//    func fill_maglog(
//        i: Int,
//        zero_padding: Int,
//        magnitudes: inout [Float],
//        mag_log: inout [Float],
//        forwardDCT: inout vDSP.DCT,
//        piece_len: Int,
//        sampleCount: Int,
//        start_idx: Int,
//        last_exp: Int,
//        hannWindow: inout [Float]
//    ) {
//
//
//        var timeDomainBuffer = [Float](repeating: 0, count: piece_len)
//        vDSP.convertElements(of: h[i..<i + piece_len], to: &timeDomainBuffer)
//        var timeDomainBufferPad = [Float](repeating: 0, count: sampleCount)
//
//        vDSP.multiply(timeDomainBuffer,
//                      hannWindow,
//                      result: &timeDomainBufferPad[0..<piece_len])
//
//
//        forwardDCT.transform(timeDomainBufferPad, result: &magnitudes)
//
//        vDSP.absolute(magnitudes, result: &magnitudes)
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

//    func genSpectrogram() -> UIImage {
//        var bufferCount: Int = 40;
//
//        //let piece_len = Int(sampleN) / bufferCount;
//        let piece_len = Int(freq.count / bufferCount);
//
//
//
//        let sc_no_padding = Int(pow(2, ceil(log2(Double(piece_len)))));
//
//        let last_exp: Int = Int(log2(Double(sc_no_padding / 2))) - 1;
//        //let last_idx: Int = Int(pow(2, floor(log2(Double(sampleCount / 2))))) - 1;
//
//        // decide best 0-padding factor
//        // trim upper segments, should be (last_exp + 1) if not
//        let len_log_no_padding = (last_exp + 1) * Int(pow(2, Double(last_exp)));
//        let zero_padding = max(Int(pow(2, floor(log2(9000 / Double(len_log_no_padding))))), 1)
//
//        let sampleCount = sc_no_padding * zero_padding;
//
//
//        var splitComplexRealInput = [Float](repeating: 0, count: sampleCount);
//        var splitComplexImaginaryInput = [Float](repeating: 0, count: sampleCount);
//
//        var freqDomainValues: [Float] = [];
//
//        var magnitudes = [Float](repeating: 0, count: sampleCount);
//
//
//        // adapted log scale y-axis
//
//        let len_log = zero_padding * len_log_no_padding;
//        //let len_log = last_exp * Int(pow(2, Double(last_exp))) * zero_padding;
//
//        // data of a column in log scale
//        var mag_log = [Float](repeating: 0, count: len_log);
//
//        // start with 10 hz
//        let start_idx = Int(floor(Double(sampleCount) / (fsamp / 20)))
//
//        let bin_duplicate = 2;
//
//        print("sc_no_padding: ", sc_no_padding)
//        print("sampleCount: ", sampleCount)
////        print("last exp: ", last_exp)
//        print("piece len: ", piece_len)
////        print("len log without pad: ", len_log_no_padding)
//        print("zero padding: ", zero_padding)
////        print("len log: ", len_log)
////        print("start idx: ", start_idx)
////        print("t.count: ", t.count)
////        print("10th: ", start_idx)
//
//        freqDomainValues.reserveCapacity(len_log * bufferCount * bin_duplicate)
//
//        var hanningWindow = vDSP.window(ofType: Float.self,
//                                        usingSequence: .hanningDenormalized,
//                                        count: piece_len,
//                                        isHalfWindow: false)
//        print("hannWindow len: ", hanningWindow.count)
//
//        //var forwardDCT = vDSP.DCT(count: sampleCount, transformType: .II)
//
//        fill_mag_log(
//            i: 0, zero_padding: zero_padding,
//            magnitudes: &magnitudes,
//            mag_log: &mag_log,
//            splitComplexRealInput: &splitComplexRealInput,
//            splitComplexImaginaryInput: &splitComplexImaginaryInput,
//            piece_len: piece_len,
//            sampleCount: sampleCount,
//            start_idx: start_idx,
//            last_exp: last_exp,
//            hannWindow: &hanningWindow
//        )
//
//
//
//        for _ in 0..<bin_duplicate {
//            freqDomainValues += mag_log
//        }
//
//        // i = 31 piece_len -> 32 piece_len
//        //for i in stride(from: 3 * piece_len, to: (bufferCount) * piece_len, by: piece_len) {
//        for i in stride(from: piece_len, to: bufferCount * piece_len, by: piece_len) {
//
//
//            fill_mag_log(
//                i: i, zero_padding: zero_padding,
//                magnitudes: &magnitudes,
//                mag_log: &mag_log,
//                splitComplexRealInput: &splitComplexRealInput,
//                splitComplexImaginaryInput: &splitComplexImaginaryInput,
//                piece_len: piece_len,
//                sampleCount: sampleCount,
//                start_idx: start_idx,
//                last_exp: last_exp,
//                hannWindow: &hanningWindow
//            )
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
//        // adapted log scale y-axis end
//
//        /*
//        print(sampleCount / 2)
//        // linear scale y-axis
//         for i in stride(from: 0, to: bufferCount * piece_len, by: piece_len) {
//             /*
//             if (truncate) {     // truncate
//                 vDSP.convertElements(of: h[i..<i + sampleCount],
//                                      to: &splitComplexRealInput);
//             } else {            // 0-padding
//                 vDSP.convertElements(of: h[i..<i + piece_len],
//                                      to: &splitComplexRealInput);
//             }*/
//
//             vDSP.convertElements(of: h[i..<i + piece_len],
//                                  to: &splitComplexRealInput);
//
//             let splitComplexDFT = try? vDSP.DiscreteFourierTransform(previous: nil,
//                                               count: sampleCount,
//                                               direction: .forward,
//                                               transformType: .complexComplex,
//                                               ofType: Float.self);
//
//             var splitComplexOutput = splitComplexDFT?.transform(real: splitComplexRealInput, imaginary: splitComplexImaginaryInput);
//
//             let forwardOutput = DSPSplitComplex(
//                 realp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.real)),
//                 imagp: UnsafeMutablePointer<Float>(&( splitComplexOutput!.imaginary)));
//
//             vDSP.absolute(forwardOutput, result: &magnitudes);
//
//             /*
//             if (i == 20 * piece_len) {
//                 print(vDSP.indexOfMaximum(magnitudes[0..<sampleCount / 2]))
//             }*/
//
//             freqDomainValues += magnitudes[0..<sampleCount / 2];
//         }
//        let len_log = sampleCount / 2;
//        // linear scale y-axis end
//        */
//
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
//        return UIImage(cgImage: result!);
//    }
//
////    func run_mode_5() {
////        let temp_coeff = pow(g * (m1 + m2) * msun / pow(Double.pi, 2), 1/3)
////        var a = freq.map { (pow($0, -2/3)) }
////        vDSP.multiply(temp_coeff, a, result: &a)
////        print(a[0...10])
////        print(temp_coeff)
////    }
//
//    func fill_mag_log(
//        i: Int,
//        zero_padding: Int,
//        magnitudes: inout [Float],
//        mag_log: inout [Float],
//        splitComplexRealInput: inout [Float],
//        splitComplexImaginaryInput: inout [Float],
//        piece_len: Int,
//        sampleCount: Int,
//        start_idx: Int,
//        last_exp: Int,
//        hannWindow: inout [Float]
//    ) {
//
//        var timeDomainBuffer = [Float](repeating: 0, count: piece_len)
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
