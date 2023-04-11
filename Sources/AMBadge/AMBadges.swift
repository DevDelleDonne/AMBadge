//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal typealias AnimationCompletion = (_ completed: Bool) -> Void

/// A shared class used to show and hide drops.
@available(iOSApplicationExtension, unavailable)
public final class AMBadges {
  /// Handler.
  public typealias DropHandler = (AmBadge) -> Void

  // MARK: - Static

  static var shared = AMBadges()

  /// Show a drop.
  /// - Parameter drop: `Drop` to show.
  public static func show(_ badge: AmBadge) {
    shared.show(badge)
  }

  /// Hide currently shown drop.
  public static func hideCurrent() {
    shared.hideCurrent()
  }

  /// Hide all drops.
  public static func hideAll() {
    shared.hideAll()
  }

  /// A handler to be called before a drop is presented.
  public static var willShowDrop: DropHandler? {
    get { shared.willShowDrop }
    set { shared.willShowDrop = newValue }
  }

  /// A handler to be called after a drop is presented.
  public static var didShowDrop: DropHandler? {
    get { shared.didShowDrop }
    set { shared.didShowDrop = newValue }
  }

  /// A handler to be called before a drop is dismissed.
  public static var willDismissDrop: DropHandler? {
    get { shared.willDismissDrop }
    set { shared.willDismissDrop = newValue }
  }

  /// A handler to be called after a drop is dismissed.
  public static var didDismissDrop: DropHandler? {
    get { shared.didDismissDrop }
    set { shared.didDismissDrop = newValue }
  }

  // MARK: - Instance

  /// Create a new instance with a custom delay between drops.
  /// - Parameter delayBetweenDrops: Delay between drops in seconds. Defaults to `0.5 seconds`.
  public init(delayBetweenDrops: TimeInterval = 0.5) {
    self.delayBetweenDrops = delayBetweenDrops
  }

  /// Show a drop.
  /// - Parameter drop: `Drop` to show.
  public func show(_ badge: AmBadge) {
    DispatchQueue.main.async {
      let presenter = Presenter(badge: badge, delegate: self)
      self.enqueue(presenter: presenter)
    }
  }

  /// Hide currently shown drop.
  public func hideCurrent() {
    guard let current = current, !current.isHiding else { return }
    willDismissDrop?(current.badge)
    DispatchQueue.main.async {
      current.hide(animated: true) { [weak self] completed in
        guard completed, let self = self else { return }
        self.dispatchQueue.sync {
          self.didDismissDrop?(current.badge)
          guard self.current === current else { return }
          self.current = nil
        }
      }
    }
  }

  /// Hide all drops.
  public func hideAll() {
    dispatchQueue.sync {
      queue.removeAll()
      hideCurrent()
    }
  }

  /// A handler to be called before a drop is presented.
  public var willShowDrop: DropHandler?

  /// A handler to be called after a drop is presented.
  public var didShowDrop: DropHandler?

  /// A handler to be called before a drop is dismissed.
  public var willDismissDrop: DropHandler?

  /// A handler to be called after a drop is dismissed.
  public var didDismissDrop: DropHandler?

  // MARK: - Helpers

  let delayBetweenDrops: TimeInterval

  let dispatchQueue = DispatchQueue(label: "com.omaralbeik.drops")
  var queue: [Presenter] = []

  var current: Presenter? {
    didSet {
      guard oldValue != nil else { return }
      let delayTime = DispatchTime.now() + delayBetweenDrops
      dispatchQueue.asyncAfter(deadline: delayTime) { [weak self] in
        self?.dequeueNext()
      }
    }
  }

  weak var autohideToken: Presenter?

  func enqueue(presenter: Presenter) {
    queue.append(presenter)
    dequeueNext()
  }

  func hide(presenter: Presenter) {
    if presenter == current {
      hideCurrent()
    } else {
      queue = queue.filter { $0 != presenter }
    }
  }

  func dequeueNext() {
    guard current == nil, !queue.isEmpty else { return }
    current = queue.removeFirst()
    autohideToken = current

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      guard let current = self.current else { return }
      self.willShowDrop?(current.badge)
      current.show { completed in
        self.didShowDrop?(current.badge)
        guard completed else {
          self.dispatchQueue.sync {
            self.hide(presenter: current)
          }
          return
        }
        if current === self.autohideToken {
          self.queueAutoHide()
        }
      }
    }
  }

  func queueAutoHide() {
    guard let current = current else { return }
    autohideToken = current
    let delayTime = DispatchTime.now() + current.badge.duration.value
    dispatchQueue.asyncAfter(deadline: delayTime) { [weak self] in
      if self?.autohideToken !== current { return }
      self?.hide(presenter: current)
    }
  }
}

extension AMBadges: AnimatorDelegate {
  func hide(animator: Animator) {
    dispatchQueue.sync { [weak self] in
      guard let presenter = self?.presenter(forAnimator: animator) else { return }
      self?.hide(presenter: presenter)
    }
  }

  func panStarted(animator _: Animator) {
    autohideToken = nil
  }

  func panEnded(animator _: Animator) {
    queueAutoHide()
  }

  private func presenter(forAnimator animator: Animator) -> Presenter? {
    if let current = current, animator === current.animator {
      return current
    }
    return queue.first { $0.animator === animator }
  }
}
#endif

