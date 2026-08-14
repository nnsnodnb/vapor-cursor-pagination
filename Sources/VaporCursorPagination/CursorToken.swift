//
//  CursorToken.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Vapor

public struct CursorToken<P: Codable, S: Codable>: Codable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case primary = "p"
    case secondary = "s"
    case reverse = "r"
  }

  // MARK: - Properties
  public let primary: P
  public let secondary: S
  public let reverse: Bool

  // MARK: - Initialize
  public init(from cursor: String) throws {
    var base64 = cursor
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    while base64.count % 4 != 0 {
      base64.append("=")
    }
    guard let data = Data(base64Encoded: base64) else {
      throw Abort(.badRequest, reason: "Invalid cursor")
    }
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    self = try jsonDecoder.decode(CursorToken<P, S>.self, from: data)
  }

  public init(primary: P, secondary: S, reverse: Bool) {
    self.primary = primary
    self.secondary = secondary
    self.reverse = reverse
  }

  // MARK: - Decodable
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.primary = try container.decode(P.self, forKey: .primary)
    self.secondary = try container.decode(S.self, forKey: .secondary)
    let reverse = try container.decode(Int.self, forKey: .reverse)
    self.reverse = reverse != 0
  }

  public func encodedString() throws -> String {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
    jsonEncoder.outputFormatting = .sortedKeys
    return try jsonEncoder.encode(self)
      .base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  // MARK: - Encodable
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(primary, forKey: .primary)
    try container.encode(secondary, forKey: .secondary)
    try container.encode(reverse ? 1 : 0, forKey: .reverse)
  }
}
