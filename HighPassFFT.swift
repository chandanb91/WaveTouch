//
//  HighPassFFT.swift
//  WaveTouch
//
//  Created by Chandan Balachandra on 05/09/2016.
//  Copyright © 2016 Chandan Balachandra. All rights reserved.
//

import Foundation
import Accelerate

class HighPassFFT{
    
    
    
    private func getFrequencies(N: Int, fps: Float) -> [Float] {
        
        // Create an Array with the Frequencies
        let freqs = (0..<N/2).map {
            fps/Float(N)*Float($0)
        }
        
        return freqs
    }
    
    private func generateHighPassFilter(freqs: [Float]) -> ([Float], Int, Int) {
        
        var minIdx = freqs.count+1
        var maxIdx = -1
        
        let highPassFilter: [Float] = freqs.enumerate().map {
            (index, element) in
            
            if (element <= self.cutoffFreq) {
                return 1.0
            } else {
                return 0.0
            }
        }
        
        for i in (0..<highPassFilter.count) {
            
            if(highPassFilter[i]==1.0) {
                
                if(i<minIdx || minIdx == freqs.count+1) {
                    minIdx=i
                }
                
                if(i>maxIdx || maxIdx == -1) {
                    maxIdx=i
                }
            }
        }
        
        assert(maxIdx != -1)
        assert(minIdx != freqs.count+1)
        
        return (highPassFilter, minIdx, maxIdx)
        
    }
    
    func sqrt(x: [Float]) -> [Float] {
        
        var results = [Float](count:x.count, repeatedValue:0.0)
        vvsqrtf(&results, x, [Int32(x.count)])
        return results
    }
    
    func max(x: [Float]) -> (Float, Int) {
        var result: Float = 0.0
        var idx : vDSP_Length = vDSP_Length(0)
        vDSP_maxvi(x, 1, &result, &idx, vDSP_Length(x.count))
        return (result, Int(idx))
    }
    
    // The bandpass frequencies
    let cutoffFreq: Float = 5.0
    let fps : Float = 256.0
    let pi = Float(M_PI)
    
    // Some Math functions on Arrays
    func mul(x: [Float], y: [Float]) -> [Float] {
        
        var results = [Float](count: x.count, repeatedValue: 0.0)
        vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))
        return results
    }
    
    
    func calculate(_input: [Float]) -> [Float] {
        
        var input = _input
        let N = input.count
        let N2 = vDSP_Length(N/2)
        let length = vDSP_Length(floor(log2(Float(input.count))))
        let radix = FFTRadix(kFFTRadix2)
        
        let weights = vDSP_create_fftsetup(length, radix)
        
        var tempComplex : [DSPComplex] = [DSPComplex](count: N/2, repeatedValue: DSPComplex())
        
        var Real : [Float] = [Float](count: N/2, repeatedValue: 0.0)
        var Imag : [Float] = [Float](count: N/2, repeatedValue: 0.0)
        var splitComplex = DSPSplitComplex(realp: &Real, imagp: &Imag)
        
        
        // For polar coordinates
        var mag : [Float] = [Float](count: N/2, repeatedValue: 0.0)
        var phase : [Float] = [Float](count: N/2, repeatedValue: 0.0)
        
        var valuesAsComplex : UnsafeMutablePointer<DSPComplex>?
        input.withUnsafeBufferPointer { (resultPointer: UnsafeBufferPointer<Float>) -> Void in
            valuesAsComplex = UnsafeMutablePointer<DSPComplex>( resultPointer.baseAddress )
        }
        
        vDSP_ctoz(valuesAsComplex!, 2, &splitComplex, 1, N2);
        vDSP_fft_zrip(weights, &splitComplex, 1, length, FFTDirection(FFT_FORWARD))
        
        var magnitudes = [Float](count: N/2, repeatedValue: 0.0)
        vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, N2)
        
        var normalizedMagnitudes = [Float](count: N/2, repeatedValue: 0.0)
        vDSP_vsmul(sqrt(magnitudes), vDSP_Stride(1), [2.0 / Float(N)], &normalizedMagnitudes, 1, N2)
        
        // Convert from complex/rectangular (real, imaginary) coordinates
        // to polar (magnitude and phase) coordinates.
        // ----------------------------------------------------------------
        
        vDSP_zvabs(&splitComplex, 1, &mag, 1, N2);
        vDSP_zvphas(&splitComplex, 1, &phase, 1, N2);
        
        // Save this variable for output
        // var fullPhases = phase
        // ----------------------------------------------------------------
        // Bandpass Filtering
        // ----------------------------------------------------------------
        
        // Get the Frequencies for the current Framerate
        let freqs = getFrequencies(N,fps: fps)
        // Get a Bandpass Filter
        let highPassFilter = generateHighPassFilter(freqs)// Multiply phase and magnitude with the bandpass filter
        
        mag = mul(mag, y: highPassFilter.0)
        phase = mul(phase, y: highPassFilter.0)
        
        // Output Variables
        let filteredSpectrum = mul(normalizedMagnitudes, y: highPassFilter.0)
        var filteredPhase = phase
        //vDSP_destroy_fftsetup(weights)
        
        // ----------------------------------------------------------------
        // Determine Maximum Frequency
        // ----------------------------------------------------------------
        let maxFrequencyResult = max(filteredSpectrum)
        let maxFrequency = freqs[maxFrequencyResult.1]
        let maxPhase = filteredPhase[maxFrequencyResult.1]
        
        print("Amplitude: \(maxFrequencyResult.0)")
        print("Frequency: \(maxFrequency)")
        print("Phase: \(maxPhase + pi/2)")
        
        // ----------------------------------------------------------------
        // Convert from polar coordinates back to rectangular coordinates.
        // ----------------------------------------------------------------
        
        splitComplex = DSPSplitComplex(realp: &mag, imagp: &phase)
        
        var complexAsValue : UnsafeMutablePointer<Float>?
        tempComplex.withUnsafeBufferPointer {
            (resultPointer: UnsafeBufferPointer<DSPComplex>) -> Void in
            complexAsValue = UnsafeMutablePointer<Float>( resultPointer.baseAddress )
        }
        
        vDSP_ztoc(&splitComplex, 1, &tempComplex, 2, N2);
        vDSP_rect(complexAsValue!, 2, complexAsValue!, 2, N2);
        vDSP_ctoz(&tempComplex, 2, &splitComplex, 1, N2);
        
        // ----------------------------------------------------------------
        // Do Inverse FFT
        // ----------------------------------------------------------------
        
        // Create result
        var result : [Float] = [Float](count: N, repeatedValue: 0.0)
        var resultAsComplex : UnsafeMutablePointer<DSPComplex>?
        
        
        result.withUnsafeBufferPointer {
            (resultPointer: UnsafeBufferPointer<Float>) -> Void in
            resultAsComplex = UnsafeMutablePointer<DSPComplex>( resultPointer.baseAddress )
        }
        
        // Do complex->real inverse FFT.
        vDSP_fft_zrip(weights, &splitComplex, 1, length, FFTDirection(FFT_INVERSE));
        
        // This leaves result in packed format. Here we unpack it into a real vector.
        vDSP_ztoc(&splitComplex, 1, resultAsComplex!, 2, N2);
        
        // Neither the forward nor inverse FFT does any scaling. Here we compensate for that.
        var scale : Float = 0.5/Float(N);
        vDSP_vsmul(&result, 1, &scale, &result, 1, vDSP_Length(N));
        
        // Print Result
        for k in (0..<N) {
            print("\(k)   \(input[k])     \(result[k])")
        }
        
        return result
    }
    
}

