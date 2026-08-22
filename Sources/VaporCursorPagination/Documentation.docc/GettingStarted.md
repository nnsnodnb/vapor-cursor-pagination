# Getting started with cursor pagination

## Overview

Import the package in the target that defines your Vapor routes.

```swift
import VaporCursorPagination
```

Use ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``
in a route handler. Choose a primary sort key that is stable for the lifetime
of a request sequence, then choose a unique tiebreaker. A timestamp and the
model ID are a common pairing.

```swift
routes.get("todos") { request async throws -> CursorPage<Todo> in
  try await Todo.query(on: request.db)
    .cursorPaginate(
      for: request,
      sortedBy: \.$created,
      direction: .descending,
      tiebreaker: \.$id,
      defaultPageSize: 20,
      maxPageSize: 100
    )
}
```

The response contains `items` and, when available, `next` and `previous`
cursors. Pass either cursor back as the `cursor` query parameter to retrieve
the adjacent page.

```text
GET /todos?cursor=<cursor-from-next-or-previous>
```

## Controlling page size

Clients can request a page size with the `size` query parameter. The package
clamps it to at least `1` and no more than `maxPageSize`; if omitted, it uses
`defaultPageSize`.

```text
GET /todos?size=50
```

## Choosing sort keys

The primary key and tiebreaker jointly define a record's position. Both must
be available on every returned model, and their combination should impose a
deterministic order. For example, use `created` as the primary key and `id`
as the tiebreaker. Avoid using a non-unique primary key without a tiebreaker,
as equal values would otherwise make pagination ambiguous.
