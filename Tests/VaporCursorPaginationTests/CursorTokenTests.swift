//
//  CursorTokenTests.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Testing
@testable import VaporCursorPagination

struct CursorTokenTests {
  @Test(
    arguments: zip(
      [true, false],
      [
        "eyJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIiwiciI6MSwicCI6MTc4NjczMzc5MDAwMH0",
        "eyJyIjowLCJwIjoxNzg2NzMzNzkwMDAwLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0"
      ]
    )
  )
  func initializeFromCursorString(reverse: Bool, cursorString: String) throws {
    let actual = try CursorToken<Date, UUID>(from: cursorString)

    let dateComponents = DateComponents(
      calendar: .init(identifier: .gregorian),
      timeZone: .init(identifier: "Asia/Tokyo"),
      year: 2026,
      month: 8,
      day: 15,
      hour: 3,
      minute: 56,
      second: 30
    )
    guard let expectPrimary = dateComponents.date else {
      Issue.record("Invalid date")
      return
    }
    let expectSecondary = UUID(uuidString: "00000000-0000-0000-0000-000000000000")

    #expect(actual.primary == expectPrimary)
    #expect(actual.secondary == expectSecondary)
    #expect(actual.reverse == reverse)
  }

  @Test(arguments: [0, 1])
  func decodeFromJSON(reverse: Int) throws {
    let jsonObject: [String: Any] = [
      "p": 1786620141595.544,
      "s": "58CBFAE1-B53A-4B47-A7F6-73B74111CB8B",
      "r": reverse
    ]
    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())

    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    let actual = try jsonDecoder.decode(CursorToken<Date, UUID>.self, from: data)

    #expect(type(of: actual.primary) == Date.self)
    #expect(actual.secondary == UUID(uuidString: "58CBFAE1-B53A-4B47-A7F6-73B74111CB8B"))
    #expect(actual.reverse == (reverse == 1))
  }

  @Test(
    arguments: zip(
      [true, false],
      [
        "eyJwIjoxNzg2NzMzNzkwMDAwLCJyIjoxLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0",
        "eyJwIjoxNzg2NzMzNzkwMDAwLCJyIjowLCJzIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIn0"
      ]
    )
  )
  func encodedString(reverse: Bool, expect: String) throws {
    let dateComponents = DateComponents(
      calendar: .init(identifier: .gregorian),
      timeZone: .init(identifier: "Asia/Tokyo"),
      year: 2026,
      month: 8,
      day: 15,
      hour: 3,
      minute: 56,
      second: 30,
      nanosecond: 0
    )
    guard let now = dateComponents.date,
          let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000") else {
      Issue.record("Invalid date")
      return
    }

    let cursor = CursorToken(primary: now, secondary: uuid, reverse: reverse)
    let actual = try cursor.encodedString()

    #expect(actual == expect, "Failed: reverse is \(reverse)")
  }
}
