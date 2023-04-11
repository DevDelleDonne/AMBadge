//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal final class PassthroughWindow: UIWindow {
  init(hitTestView: UIView) {
    self.hitTestView = hitTestView
    super.init(frame: .zero)
  }

  required init?(coder _: NSCoder) {
    return nil
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    if let view = view, let hitTestView = hitTestView, hitTestView.isDescendant(of: view), hitTestView != view {
      return nil
    }
    return view
  }

  private weak var hitTestView: UIView?
}
#endif

