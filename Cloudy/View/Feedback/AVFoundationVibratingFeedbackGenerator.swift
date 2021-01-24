// Copyright (c) 2020 Nomad5. All rights reserved.

import UIKit
import AVFoundation

/// The different types of feedback
@objc enum TouchFeedbackType: Int {
    case off      = 0
    case acoustic = 1
    case vibrate  = 2
    case all      = 3
}

/// Protocol to generate touch feedback
@objc protocol TouchFeedbackGenerator {

    /// Set the feedback type to the given types
    func setFeedbackType(_ type: TouchFeedbackType)
    /// Trigger feedback generation
    func generateFeedback()
}

class AVFoundationVibratingFeedbackGenerator: TouchFeedbackGenerator {

    private let vibrateGenerator    = UIImpactFeedbackGenerator(style: .light)
    private var currentFeedbackType = UserDefaults.standard.touchFeedbackType

    /// Set the type
    func setFeedbackType(_ type: TouchFeedbackType) {
        currentFeedbackType = type
    }

    /// Generate feedback
    func generateFeedback() {
        switch currentFeedbackType {
            case .acoustic:
                generateAcousticFeedback()
            case .vibrate:
                generateHapticFeedback()
            case .all:
                generateAcousticFeedback()
                generateHapticFeedback()
            case .off:
                break
        }
    }

    /// Acoustic feedback
    private func generateAcousticFeedback() {
        AudioServicesPlayAlertSoundWithCompletion(1306, nil)
    }

    /// Haptic feedback
    private func generateHapticFeedback() {
        vibrateGenerator.impactOccurred(intensity: 0.5)
    }

}