//
//  QueryBuilder+Extensions.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import FluentKit
import Foundation
import Vapor

extension QueryBuilder {
  public func cursorPaginate<P: QueryableProperty, S: QueryableProperty>(
    for request: Request,
    sortedBy primaryKeyPath: KeyPath<Model, P>,
    direction: CursorPageDirection = .descending,
    tiebreaker secondaryKeyPath: KeyPath<Model, S>,
    defaultPageSize: Int = 20,
    maxPageSize: Int = 100,
  ) async throws -> CursorPage<Model> where P.Model == Model, S.Model == Model {
    let query = try request.query.decode(CursorPageRequest.self)
    let pageSize = Swift::min(Swift::max(query.size ?? defaultPageSize, 1), maxPageSize)

    let reverse: Bool
    let primaryPosition: P.Value?
    let secondaryPosition: S.Value?

    if let cursor = query.cursor {
      let cursorToken = try CursorToken<P.Value, S.Value>(from: cursor)
      reverse = cursorToken.reverse
      primaryPosition = cursorToken.primary
      secondaryPosition = cursorToken.secondary
    } else {
      reverse = false
      primaryPosition = nil
      secondaryPosition = nil
    }

    let queryAscending = if reverse {
      direction != .ascending
    } else {
      direction == .ascending
    }
    let sortDirection: DatabaseQuery.Sort.Direction = queryAscending ? .ascending : .descending

    var builder = self
      .sort(primaryKeyPath, sortDirection)
      .sort(secondaryKeyPath, sortDirection)

    if let primaryPosition, let secondaryPosition {
      let primaryMethod: DatabaseQuery.Filter.Method = queryAscending ? .greaterThan : .lessThan
      let secondaryMethod: DatabaseQuery.Filter.Method = queryAscending ? .greaterThan : .lessThan

      builder = builder.group(.or) { group in
        group.filter(primaryKeyPath, primaryMethod, primaryPosition)
        group.group(.and) { query in
          query.filter(primaryKeyPath, .equal, primaryPosition)
          query.filter(secondaryKeyPath, secondaryMethod, secondaryPosition)
        }
      }
    }

    var items = try await builder.limit(pageSize + 1).all()
    let hasMore = items.count > pageSize
    if hasMore {
      items.removeLast()
    }
    if reverse {
      items.reverse()
    }

    let hasNext = reverse ? (primaryPosition != nil) : hasMore
    let hasPrevious = reverse ? hasMore : (primaryPosition != nil)

    var nextCursor: String?
    var previousCursor: String?

    if hasNext, let last = items.last,
       let primary = last[keyPath: primaryKeyPath].value,
       let secondary = last[keyPath: secondaryKeyPath].value {
      nextCursor = try CursorToken(primary: primary, secondary: secondary, reverse: false).encodedString()
    }

    if hasPrevious, let first = items.first,
       let primary = first[keyPath: primaryKeyPath].value,
       let secondary = first[keyPath: secondaryKeyPath].value {
      previousCursor = try CursorToken(primary: primary, secondary: secondary, reverse: true).encodedString()
    }

    return CursorPage(
      items: items,
      next: nextCursor,
      previous: previousCursor,
    )
  }
}

