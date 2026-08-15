//
//  QueryBuilder+ExtensionsTests.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Fluent
import FluentSQLiteDriver
import Testing
@testable import VaporCursorPagination
import VaporTesting

private func withMigrationApp(_ test: (Application) async throws -> ()) async throws {
  let app = try await Application.make(.testing)
  do {
    app.databases.use(.sqlite(.memory), as: .sqlite)
    app.migrations.add(CreateTodoMigration())
    try await app.autoMigrate()
    try await test(app)
    try await app.autoRevert()
  } catch {
    try? await app.autoRevert()
    try await app.asyncShutdown()
    throw error
  }
  try await app.asyncShutdown()
}

struct QueryBuilderExtensionsTests {
  @discardableResult
  private func initialTodos(on database: any Database) async throws -> [TestTodo] {
    var todos: [TestTodo] = []
    for index in 1..<30 {
      let dateComponents = DateComponents(
        calendar: .init(identifier: .gregorian),
        timeZone: .init(identifier: "Asia/Tokyo"),
        year: 2026,
        month: 8,
        day: 15,
        hour: 3,
        minute: 56,
        second: index
      )
      guard let created = dateComponents.date else {
        Issue.record("Invalid date")
        break
      }
      let id = UUID(uuidString: String(format: "00000000-0000-0000-0000-0000000000%.2d", index))
      let todo = TestTodo(id: id, title: "Test \(index)", created: created)
      try await todo.save(on: database)
      todos.append(todo)
    }
    return todos
  }

  private func addTodoRoute(_ app: Application, maxPageSize: Int = 100) {
    app.get("todos") { request -> CursorPage<TestTodo> in
      try await TestTodo
        .query(on: request.db)
        .cursorPaginate(
          for: request,
          sortedBy: \.$created,
          tiebreaker: \.$id,
          maxPageSize: maxPageSize,
        )
    }
  }

  @Test
  func initialRequest() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 20)
          for (actualItem, expectIndex) in zip(actual.items, (10..<30).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzcwMDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDEwIn0")
          #expect(actual.previous == nil)
        },
      )
    }
  }

  @Test
  func initialRequestWithSizeParameter() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?size=4",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 4)
          for (actualItem, expectIndex) in zip(actual.items, (26..<30).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzg2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI2In0")
          print(actual.next!)
          #expect(actual.previous == nil)
        },
      )
    }
  }

  @Test
  func nextRequestWithCursorParameter() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?cursor=eyJwIjoxNzg2NzMzNzg2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI2In0",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 20)
          for (actualItem, expectIndex) in zip(actual.items, (6..<26).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzY2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDA2In0")
          #expect(
            actual.previous == "eyJwIjoxNzg2NzMzNzg1MDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI1In0"
          )
        },
      )
    }
  }

  @Test
  func nextRequestWithCursorAndSizeParameter() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?size=4&cursor=eyJwIjoxNzg2NzMzNzg2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI2In0",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 4)
          for (actualItem, expectIndex) in zip(actual.items, (22..<26).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzgyMDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDIyIn0")
          #expect(
            actual.previous == "eyJwIjoxNzg2NzMzNzg1MDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI1In0"
          )
        },
      )
    }
  }

  @Test
  func previousRequestWithCursorParameter() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?cursor=eyJwIjoxNzg2NzMzNzg1MDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI1In0",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 4)
          for (actualItem, expectIndex) in zip(actual.items, (26..<30).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzg2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI2In0")
          #expect(actual.previous == nil)
        },
      )
    }
  }

  @Test
  func previousRequestWithCursorAndSizeParameter() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?size=2&cursor=eyJwIjoxNzg2NzMzNzg1MDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI1In0",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 2)
          for (actualItem, expectIndex) in zip(actual.items, (26..<28).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzg2MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI2In0")
          #expect(
            actual.previous == "eyJwIjoxNzg2NzMzNzg3MDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI3In0"
          )
        },
      )
    }
  }

  @Test
  func overMaxPageSize() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app, maxPageSize: 2)

      try await app.testing().test(
        .GET,
        "todos/?size=3",
        afterResponse: { response in
          #expect(response.status == .ok)
          let actual = try response.content.decode(CursorPage<TestTodo>.self, as: .json)
          #expect(actual.items.count == 2)
          for (actualItem, expectIndex) in zip(actual.items, (28..<30).reversed()) {
            #expect(actualItem.title == "Test \(expectIndex)")
          }
          #expect(actual.next == "eyJwIjoxNzg2NzMzNzg4MDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDI4In0")
          #expect(actual.previous == nil)
        },
      )
    }
  }

  @Test
  func invalidCursorString() async throws {
    try await withMigrationApp { app in
      try await initialTodos(on: app.db)
      addTodoRoute(app)

      try await app.testing().test(
        .GET,
        "todos/?cursor=invalid_cursor",
        afterResponse: { response in
          #expect(response.status == .badRequest)
        },
      )
    }
  }
}
