//
//  CursorPageRequest.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Vapor

public struct CursorPageRequest: Content {
  // MARK: - Properties
  public var cursor: String?
  public var size: Int?

  // MARK: - Initialize
  public init(cursor: String? = nil, size: Int? = nil) {
    self.cursor = cursor
    self.size = size
  }
}
