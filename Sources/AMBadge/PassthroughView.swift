//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
import UIKit

internal final class PassthroughView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    return view == self ? nil : view
  }
}
#endif
