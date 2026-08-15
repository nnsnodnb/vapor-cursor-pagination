//
//  CursorPageRequestTests.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Testing
@testable import VaporCursorPagination

struct CursorPageRequestTests {
  @Test
  func decodeAllFields() throws {
    let jsonObject: [String: Any] = [
      "cursor": "eyJyIjowLCJwIjoxNzg2NzMzNzkwMDAwLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0",
      "size": 20
    ]
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let actual = try JSONDecoder().decode(CursorPageRequest.self, from: data)

    #expect(actual.cursor == "eyJyIjowLCJwIjoxNzg2NzMzNzkwMDAwLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0")
    #expect(actual.size == 20)
  }

  @Test
  func decodeAllFieldsNil() throws {
    var jsonObject: [String: Any] = [:]
    jsonObject["cursor"] = nil
    jsonObject["size"] = nil
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let actual = try JSONDecoder().decode(CursorPageRequest.self, from: data)

    #expect(actual.cursor == nil)
    #expect(actual.size == nil)
  }

  @Test
  func decodeOnlySizeField() throws {
    let jsonObject: [String: Any] = [
      "size": 20
    ]
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let actual = try JSONDecoder().decode(CursorPageRequest.self, from: data)

    #expect(actual.cursor == nil)
    #expect(actual.size == 20)
  }

  @Test
  func decodeOnlyCursorField() throws {
    let jsonObject: [String: Any] = [
      "cursor": "eyJyIjowLCJwIjoxNzg2NzMzNzkwMDAwLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0"
    ]
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let actual = try JSONDecoder().decode(CursorPageRequest.self, from: data)

    #expect(actual.cursor == "eyJyIjowLCJwIjoxNzg2NzMzNzkwMDAwLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0")
    #expect(actual.size == nil)
  }

  @Test
  func decodeEmptyFields() throws {
    let jsonObject: [String: Any] = [:]
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let actual = try JSONDecoder().decode(CursorPageRequest.self, from: data)

    #expect(actual.cursor == nil)
    #expect(actual.size == nil)
  }
}
