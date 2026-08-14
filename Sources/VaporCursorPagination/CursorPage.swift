//
//  CursorPage.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import FluentKit
import Foundation
import Vapor

public struct CursorPage<T: Model>: Content {
  // MARK: - Properties
  public let items: [T]
  public let next: String?
  public let previous: String?

  // MARK: - Initialize
  public init(items: [T], next: String?, previous: String?) {
    self.items = items
    self.next = next
    self.previous = previous
  }
}
