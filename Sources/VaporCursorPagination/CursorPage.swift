//
//  CursorPage.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import FluentKit
import Foundation
import Vapor

/// A page of models returned by cursor pagination.
///
/// A page includes the current items and opaque cursors for requesting the
/// adjacent pages. A missing cursor means that no page exists in that direction.
///
/// `T` is the [`Model`](https://api.vapor.codes/fluentkit/model/) type contained in the page, matching the model type
/// of the query that produced it.
///
/// - SeeAlso: ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``

public struct CursorPage<T: Model>: Content {
  // MARK: - Properties
  /// The models in the current page.
  public let items: [T]

  /// An opaque cursor for the next page, or `nil` when this is the last page.
  public let next: String?

  /// An opaque cursor for the previous page, or `nil` when this is the first page.
  public let previous: String?

  // MARK: - Initializers
  /// Creates a page from models and navigation cursors.
  ///
  /// - Parameters:
  ///   - items: The models in the current page.
  ///   - next: An opaque cursor for the next page, or `nil` when this is the last page.
  ///   - previous: An opaque cursor for the previous page, or `nil` when this is the first page.
  public init(items: [T], next: String?, previous: String?) {
    self.items = items
    self.next = next
    self.previous = previous
  }
}
