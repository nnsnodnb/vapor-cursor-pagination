//
//  CursorPageDirection.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation

/// The order used for the initial cursor pagination query.
///
/// - SeeAlso: ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``
public enum CursorPageDirection: Sendable {
  /// Orders results from the lowest primary sort value to the highest.
  case ascending
  /// Orders results from the highest primary sort value to the lowest.
  case descending
}
