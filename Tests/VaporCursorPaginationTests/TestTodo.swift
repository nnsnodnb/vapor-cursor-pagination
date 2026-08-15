//
//  TestTodo.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import FluentKit
import Foundation

final class TestTodo: Model, @unchecked Sendable {
  // MARK: - Properties
  static let schema = "todos"

  @ID(key: .id)
  var id: UUID?
  @Field(key: "title")
  var title: String
  @Timestamp(key: "created", on: .none, format: .default)
  var created: Date?

  // MARK: - Initialize
  init() {
  }

  init(id: UUID? = nil, title: String, created: Date? = nil) {
    self.id = id
    self.title = title
    self.created = created
  }
}

struct CreateTodoMigration: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema(TestTodo.schema)
      .id()
      .field("title", .string, .required)
      .field("created", .datetime, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema(TestTodo.schema).delete()
  }
}
