//
//  CursorToken.swift
//  VaporCursorPagination
//
//  Created by Yuya Oka on 2026/08/15.
//

import Foundation
import Vapor

/// The codable value encoded into a cursor string.
///
/// This type is public to support custom cursor handling, but applications
/// normally obtain cursor strings from ``CursorPage/next`` or
/// ``CursorPage/previous`` and pass them back in a request rather than
/// decoding them directly.
///
/// `P` is the primary sort value type and `S` is the secondary (tiebreaker)
/// sort value type, matching the key path value types passed to
/// ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``.
public struct CursorToken<P: Codable, S: Codable>: Codable {
  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case primary = "p"
    case secondary = "s"
    case reverse = "r"
  }

  // MARK: - Properties
  /// The primary sort value at the cursor position.
  public let primary: P

  /// The tiebreaker sort value at the cursor position.
  public let secondary: S

  /// Whether the cursor requests records before its position.
  public let reverse: Bool

  // MARK: - Initializers
  /// Decodes a URL-safe base64 cursor string.
  ///
  /// - Parameter cursor: A URL-safe base64 string, typically obtained from
  ///   ``CursorPage/next`` or ``CursorPage/previous``.
  /// - Throws: An `Abort` bad-request error when the string is not valid
  ///   base64, or a `DecodingError` when the decoded JSON does not match
  ///   `P` and `S`.
  public init(from cursor: String) throws {
    var base64 = cursor
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let paddingCount = 4 - (base64.count % 4)
    let padding = String(repeating: "=", count: paddingCount)
    base64.append(padding)
    guard let data = Data(base64Encoded: base64) else {
      throw Abort(.badRequest, reason: "Invalid cursor")
    }
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    self = try jsonDecoder.decode(CursorToken<P, S>.self, from: data)
  }

  /// Creates a cursor token from its position and navigation direction.
  ///
  /// - Parameters:
  ///   - primary: The primary sort value at the cursor position.
  ///   - secondary: The tiebreaker sort value at the cursor position.
  ///   - reverse: Whether the cursor requests records before its position.
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

  /// Encodes the token as a URL-safe base64 cursor string.
  ///
  /// - Throws: An error if the underlying `JSONEncoder` fails to encode `P` or `S`.
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
