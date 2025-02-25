//
//  RainbowLoader.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/219/25.
//

import UIKit

class CactusLoader: UIView {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(systemName: "cactus.fill")) // SF Symbol
    imageView.tintColor = UIColor.systemGreen
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private var bounceTimer: Timer?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  private func setupUI() {
    addSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 50),
      imageView.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
  
  /// Starts the bouncing and pulsing animation.
  func startAnimating() {
    isHidden = false
    startPulsing()
    startBouncing()
  }
  
  /// Stops the animation and hides the loader.
  func stopAnimating() {
    isHidden = true
    bounceTimer?.invalidate()
    bounceTimer = nil
  }
  
  private func startPulsing() {
    let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
    pulseAnimation.fromValue = 1.0
    pulseAnimation.toValue = 1.2
    pulseAnimation.duration = 0.6
    pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    pulseAnimation.autoreverses = true
    pulseAnimation.repeatCount = .infinity
    imageView.layer.add(pulseAnimation, forKey: "pulse")
  }
  
  private func startBouncing() {
    bounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
      self?.moveToRandomPosition()
    }
  }
  
  private func moveToRandomPosition() {
    guard let superview = superview else { return }
    
    let maxX = superview.bounds.width - self.bounds.width
    let maxY = superview.bounds.height - self.bounds.height
    let randomX = CGFloat.random(in: 50...maxX - 50)
    let randomY = CGFloat.random(in: 100...maxY - 100)
    
    UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
      self.frame.origin = CGPoint(x: randomX, y: randomY)
    }
  }
}
