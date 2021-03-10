// Copyright (c) 2020 Nomad5. All rights reserved.

import UIKit

extension UIView {

    func fadeIn() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }

    func fadeOut(with completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2,
                       animations: { self.alpha = 0 },
                       completion: { _ in completion?() })
    }

    func fillParent() {
        guard let superview = superview else { return }
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }

    func placeOnParent() {
        guard let superview = superview else { return }
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        translatesAutoresizingMaskIntoConstraints = false
    }

    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

    }

    func addGlowAnimation(withColor color: UIColor) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero
        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 15
        glowAnimation.fillMode = .removed
        glowAnimation.repeatCount = .infinity
        glowAnimation.duration = 2
        glowAnimation.autoreverses = true
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }

    func animate(in visible: Bool, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                           self?.transform = CGAffineTransform(scaleX: visible ? 1 : 0.75,
                                                               y: visible ? 1 : 0.75)
                           self?.alpha = visible ? 1 : 0
                       },
                       completion: { _ in completion?() })
    }
}


