//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal final class Presenter: NSObject {
  init(badge: AmBadge, delegate: AnimatorDelegate) {
    self.badge = badge
    view = DropView(badge: badge)
    viewController = .init(value: WindowViewController())
    animator = Animator(position: badge.position, delegate: delegate)
    context = AnimationContext(view: view, container: maskingView)
  }

  let badge: AmBadge
  let animator: Animator
  var isHiding = false

  func show(completion: @escaping AnimationCompletion) {
    install()
    animator.show(context: context) { [weak self] completed in
      if let badge = self?.badge {
        self?.announcementAccessibilityMessage(for: badge)
      }
      completion(completed)
    }
  }

  func hide(animated: Bool, completion: @escaping AnimationCompletion) {
    isHiding = true
    let action = { [weak self] in
      self?.viewController.value?.uninstall()
      self?.maskingView.removeFromSuperview()
      completion(true)
    }
    guard animated else {
      action()
      return
    }
    animator.hide(context: context) { _ in
      action()
    }
  }

  let maskingView = PassthroughView()
  let view: UIView
  let viewController: Weak<WindowViewController>
  let context: AnimationContext

  func install() {
    guard let container = viewController.value else { return }
    guard let containerView = container.view else { return }

    container.install()

    maskingView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(maskingView)

    NSLayoutConstraint.activate([
      maskingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      maskingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      maskingView.topAnchor.constraint(equalTo: containerView.topAnchor),
      maskingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])

    containerView.layoutIfNeeded()
  }

  func announcementAccessibilityMessage(for badge: AmBadge) {
    UIAccessibility.post(
      notification: UIAccessibility.Notification.announcement,
      argument: badge.accessibility.message
    )
  }
}
#endif

