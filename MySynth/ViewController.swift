//
//  ViewController.swift
//  MySynth
//
//  Created by Mike Gazzaruso on 11/03/17.
//  Copyright © 2017 Test Company. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Create our Oscillator using a Sawtooth Waveform Table
    var oscillator: AKOscillator!
    
    // Create a Lowpass Filter and applies it to our Oscillator output
    var filter: AKLowPassFilter!
    
    // Create an ADSR Envelope and applies it to our Filter output
    var envelope: AKAmplitudeEnvelope!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        setupUI()
    }
    
    // Setup Audio Layer
    private func setupAudio() {
        // Setup the Oscillator with a Sawtooth Waveform Table
        self.oscillator = AKOscillator(waveform: AKTable(.sawtooth))
        
        // Setup the Lowpass Filter with an initial Cutoff of 22000, almost no filtering
        self.filter = AKLowPassFilter(oscillator, cutoffFrequency: 22000.0, resonance: 0.2)
        // Setup the ADSR Envelope and apply it to our Lowpass filter output
        self.envelope = AKAmplitudeEnvelope(self.filter, attackDuration: 0.01, decayDuration: 0.1, sustainLevel: 1.0, releaseDuration: 0.1)
        
        // Setting AudioKit's output with our ADSR Envelope (our third and last block)
        AudioKit.output = self.envelope
        
        // Start AudioKit Engine
        try! AudioKit.start()
    }
    
    // Setup Graphic User Interface
    private func setupUI() {
        // Create AKKeyboardView and, set some constraints to it and setting self as delegate
        let keyboard = AKKeyboardView(width: 0,
                                      height: 0, firstOctave: 3, octaveCount: 3)
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(keyboard)
        let yPosConstraint = NSLayoutConstraint(item: keyboard, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.85, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: keyboard, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.15, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: keyboard, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        keyboard.delegate = self
        
        // Set Attack, Decay, Sustain and Release sliders and set their constraints
        // Attack
        let attackSlider = AKSlider(
            property: "ENV Attack",
            value: self.envelope.attackDuration, range: 0.01 ... 1000.0, taper: 1.0, format: "%0.2f ms"
        ) { attackValue in
            self.envelope.attackDuration = attackValue / 1000
        }
        attackSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(attackSlider)
        let atkWidthConstraint = NSLayoutConstraint(item: attackSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let atkHeightContraint = NSLayoutConstraint(item: attackSlider, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0)
        
        // Decay
        let decaySlider = AKSlider(
            property: "ENV Decay",
            value: self.envelope.decayDuration, range: 0.1 ... 1000.0, taper: 1.0, format: "%0.1f ms"
        ) { decayValue in
            self.envelope.decayDuration = decayValue / 1000
        }
        decaySlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(decaySlider)
        let dcyWidthConstraint = NSLayoutConstraint(item: decaySlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let dcyHeightContraint = NSLayoutConstraint(item: decaySlider, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0)
        let dcyUpperContraint = NSLayoutConstraint(item: decaySlider, attribute: .top, relatedBy: .equal, toItem: attackSlider, attribute: .bottom, multiplier: 1.0, constant: 8)
        
        // Sustain
        let sustainSlider = AKSlider(
            property: "ENV Sustain",
            value: self.envelope.sustainLevel, range: 0.0 ... 1.0, taper: 1.0, format: "%0.1f"
        ) { sustainLevel in
            self.envelope.sustainLevel = sustainLevel
        }
        sustainSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sustainSlider)
        let stnWidthConstraint = NSLayoutConstraint(item: sustainSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let stnHeightContraint = NSLayoutConstraint(item: sustainSlider, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0)
        let stnUpperContraint = NSLayoutConstraint(item: sustainSlider, attribute: .top, relatedBy: .equal, toItem: decaySlider, attribute: .bottom, multiplier: 1.0, constant: 8)
        
        // Release
        let releaseSlider = AKSlider(
            property: "ENV Release",
            value: self.envelope.releaseDuration, range: 0.1 ... 1000.0, taper: 1000.0, format: "%0.1f ms"
        ) { releaseDuration in
            self.envelope.releaseDuration = releaseDuration / 1000
        }
        releaseSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(releaseSlider)
        let rlsWidthConstraint = NSLayoutConstraint(item: releaseSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let rlsHeightContraint = NSLayoutConstraint(item: releaseSlider, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0)
        let rlsUpperContraint = NSLayoutConstraint(item: releaseSlider, attribute: .top, relatedBy: .equal, toItem: sustainSlider, attribute: .bottom, multiplier: 1.0, constant: 8)
        
        // Filter Cutoff and Resonance
        let filterSlider = AKSlider(
            property: "FILTER",
            value: self.filter.cutoffFrequency, range: 1.0 ... 22050.0, taper: 1.0, format: "%0.f Hz"
        ) { filterVariation in
            self.filter.cutoffFrequency = filterVariation
            self.filter.resonance = 1.0 - (filterVariation / 22050.0)
        }
        filterSlider.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(filterSlider)
        let fltWidthConstraint = NSLayoutConstraint(item: filterSlider, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0)
        let fltHeightContraint = NSLayoutConstraint(item: filterSlider, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0)
        let fltUpperContraint = NSLayoutConstraint(item: filterSlider, attribute: .top, relatedBy: .equal, toItem: releaseSlider, attribute: .bottom, multiplier: 1.0, constant: 8)
        
        // Activate the constraints
        NSLayoutConstraint.activate([yPosConstraint, heightConstraint, widthConstraint, atkWidthConstraint, atkHeightContraint, dcyWidthConstraint, dcyHeightContraint, dcyUpperContraint, stnWidthConstraint, stnHeightContraint, stnUpperContraint, rlsWidthConstraint, rlsHeightContraint, rlsUpperContraint, fltWidthConstraint, fltHeightContraint, fltUpperContraint])
    }
}

// AKKeyboardDelegate methods
extension ViewController: AKKeyboardDelegate {
    func noteOn(note: MIDINoteNumber) {
        self.oscillator.frequency = note.midiNoteToFrequency()
        self.envelope.start()
        self.oscillator.play()
    }
    
    func noteOff(note: MIDINoteNumber) {
        let mainQueue = DispatchQueue.main
        let deadline = DispatchTime.now() + .milliseconds(Int(self.envelope.releaseDuration * 1000))
        mainQueue.asyncAfter(deadline: deadline) {
            self.oscillator.stop()
            self.envelope.stop()
        }
    }
}
