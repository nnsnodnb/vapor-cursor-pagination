//
//  CursorPageRequest.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Vapor

/// Pagination parameters decoded from an HTTP request's query string.
public struct CursorPageRequest: Content {
  // MARK: - Properties
  /// An opaque cursor returned by a previous page's ``CursorPage/next`` or
  /// ``CursorPage/previous`` value.
  public var cursor: String?

  /// The requested number of items in the page.
  ///
  /// This value is honored within the `defaultPageSize` and `maxPageSize` bounds
  /// passed to ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``.
  public var size: Int?

  // MARK: - Initializers
  /// Creates pagination parameters.
  ///
  /// - Parameters:
  ///   - cursor: An opaque cursor returned by a previous page's ``CursorPage/next``
  ///     or ``CursorPage/previous`` value.
  ///   - size: The requested number of items in the page.
  public init(cursor: String? = nil, size: Int? = nil) {
    self.cursor = cursor
    self.size = size
  }
}
