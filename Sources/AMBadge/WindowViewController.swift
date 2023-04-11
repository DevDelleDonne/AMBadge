//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal final class WindowViewController: UIViewController {
  init() {
    let view = PassthroughView()
    let window = PassthroughWindow(hitTestView: view)
    self.window = window
    super.init(nibName: nil, bundle: nil)
    self.view = view
    window.rootViewController = self
  }

  required init?(coder _: NSCoder) {
    return nil
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    // Workaround for https://github.com/omaralbeik/Drops/pull/22
    let app = UIApplication.shared
    let windowScene = app.activeWindowScene
    let topViewController = windowScene?.windows.first(where: \.isKeyWindow)?.rootViewController?.top
    return topViewController?.preferredStatusBarStyle
      ?? windowScene?.statusBarManager?.statusBarStyle
      ?? .default
  }

  func install() {
    window?.frame = UIScreen.main.bounds
    window?.isHidden = false
    if let window = window, let activeScene = UIApplication.shared.activeWindowScene {
      window.windowScene = activeScene
      window.frame = activeScene.coordinateSpace.bounds
    }
  }

  func uninstall() {
    window?.isHidden = true
    window?.windowScene = nil
    window = nil
  }

  var window: UIWindow?
}

internal extension UIApplication {
  var activeWindowScene: UIWindowScene? {
    return connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState == .foregroundActive }
  }
}

internal extension UIViewController {
  var top: UIViewController? {
    if let controller = self as? UINavigationController {
      return controller.topViewController?.top
    }
    if let controller = self as? UISplitViewController {
      return controller.viewControllers.last?.top
    }
    if let controller = self as? UITabBarController {
      return controller.selectedViewController?.top
    }
    if let controller = presentedViewController {
      return controller.top
    }
    return self
  }
}
#endif
