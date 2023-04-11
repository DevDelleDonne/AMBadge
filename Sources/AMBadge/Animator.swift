//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal protocol AnimatorDelegate: AnyObject {
  func hide(animator: Animator)
  func panStarted(animator: Animator)
  func panEnded(animator: Animator)
}

internal final class Animator {
  struct PanState: Equatable {
    var closing = false
    var closeSpeed: CGFloat = 0.0
    var closePercent: CGFloat = 0.0
    var panTranslationY: CGFloat = 0.0
  }

  init(position: AmBadge.Position, delegate: AnimatorDelegate) {
    self.position = position
    self.delegate = delegate
  }

  let position: AmBadge.Position
  weak var delegate: AnimatorDelegate?

  var context: AnimationContext?
  var panState = PanState()

  let showDuration: TimeInterval = 0.75
  let hideDuration: TimeInterval = 0.25
  let springDamping: CGFloat = 0.8
  let rubberBanding = true
  let closeSpeedThreshold: CGFloat = 750.0
  let closePercentThreshold: CGFloat = 0.33
  let closeAbsoluteThreshold: CGFloat = 75.0
  let bounceOffset: CGFloat = 5

  private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let recognizer = UIPanGestureRecognizer()
    recognizer.addTarget(self, action: #selector(handlePan))
    return recognizer
  }()

  func install(context: AnimationContext) {
    let view = context.view
    let container = context.container

    self.context = context

    view.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(view)

    var constraints = [
      view.centerXAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerXAnchor),
      view.leadingAnchor.constraint(greaterThanOrEqualTo: container.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      view.trailingAnchor.constraint(lessThanOrEqualTo: container.safeAreaLayoutGuide.trailingAnchor, constant: -20)
    ]

    switch position {
    case .bottom:
      constraints += [
        view.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -bounceOffset)
      ]
    }

    NSLayoutConstraint.activate(constraints)
    container.layoutIfNeeded()

    let animationDistance = view.frame.height

    switch position {
    case .bottom:
      view.transform = CGAffineTransform(translationX: 0, y: animationDistance)
    }

    view.addGestureRecognizer(panGestureRecognizer)
  }

  func show(context: AnimationContext, completion: @escaping AnimationCompletion) {
    install(context: context)
    show(completion: completion)
  }

  func hide(context: AnimationContext, completion: @escaping AnimationCompletion) {
    let position = self.position
    let view = context.view
    UIView.animate(
      withDuration: hideDuration,
      delay: 0,
      options: [.beginFromCurrentState, .curveEaseIn],
      animations: { [weak view] in
        view?.alpha = 0
        let frame = view?.frame ?? .zero
        switch position {
        case .bottom:
          view?.transform = CGAffineTransform(translationX: 0, y: frame.height)
        }
      },
      completion: completion
    )
  }

  func show(completion: @escaping AnimationCompletion) {
    guard let view = context?.view else {
      completion(false)
      return
    }

    view.alpha = 0

    let animationDistance = abs(view.transform.ty)
    let initialSpringVelocity = animationDistance == 0.0 ? 0.0 : min(0.0, panState.closeSpeed / animationDistance)

    UIView.animate(
      withDuration: showDuration,
      delay: 0.0,
      usingSpringWithDamping: springDamping,
      initialSpringVelocity: initialSpringVelocity,
      options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
      animations: { [weak view] in
        view?.alpha = 1
        view?.transform = .identity
      },
      completion: completion
    )
  }

  @objc
  func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .changed:
      guard let view = context?.view else { return }
      let velocity = gestureRecognizer.velocity(in: view)
      let translation = gestureRecognizer.translation(in: view)
      panState = panChanged(current: panState, view: view, velocity: velocity, translation: translation)
    case .ended, .cancelled:
      if let initialState = panEnded(current: panState) {
        show { [weak self] _ in
          guard let self = self else { return }
          self.delegate?.panEnded(animator: self)
        }
        panState = initialState
      }
    default:
      break
    }
  }

  func panChanged(current: PanState, view: UIView, velocity: CGPoint, translation: CGPoint) -> PanState {
    var state = current
    var velocity = velocity
    var translation = translation
    let height = view.bounds.height - bounceOffset
    if height <= 0 { return state }

    var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)

    if !state.closing {
      if !rubberBanding, translationAmount < 0 { return state }
      state.closing = true
      delegate?.panStarted(animator: self)
    }

    if !rubberBanding, translationAmount < 0 { translationAmount = 0 }

    switch position {
    case .bottom:
      view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
    }

    state.closeSpeed = velocity.y
    state.closePercent = translation.y / height
    state.panTranslationY = translation.y

    return state
  }

  func panEnded(current: PanState) -> PanState? {
    if current.closeSpeed > closeSpeedThreshold {
      delegate?.hide(animator: self)
      return nil
    }

    if current.closePercent > closePercentThreshold {
      delegate?.hide(animator: self)
      return nil
    }

    if current.panTranslationY > closeAbsoluteThreshold {
      delegate?.hide(animator: self)
      return nil
    }

    return .init()
  }
}
#endif
