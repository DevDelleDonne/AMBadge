//
//  File.swift
//  
//
//  Created by Alberto Delle Donne on 11/04/23.
//

#if os(iOS)
internal struct Weak<T: AnyObject> {
  init(value: T?) {
    self.value = value
  }

  weak var value: T?
}
#endif

