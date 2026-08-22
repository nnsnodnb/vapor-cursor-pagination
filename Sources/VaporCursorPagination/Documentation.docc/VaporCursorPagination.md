# ``VaporCursorPagination``

Cursor-based pagination for Vapor applications using Fluent queries.

## Overview

``VaporCursorPagination`` adds cursor pagination to Fluent's [`QueryBuilder`](https://api.vapor.codes/fluentkit/querybuilder/).
It returns a ``CursorPage`` containing the current items and opaque cursors for
navigating forward and backward without relying on offset-based pagination.

Use a stable primary sort key, such as a creation timestamp, together with a
unique tiebreaker. The two values are encoded into each cursor, so items are
not skipped or repeated when several records share the same primary value.

## Topics

### Paginating queries

- ``VaporCursorPagination/FluentKit/QueryBuilder/cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)``
- ``CursorPageDirection``

### Working with pages and requests

- ``CursorPage``
- ``CursorPageRequest``

### Cursor representation

- ``CursorToken``

### Essentials

- <doc:GettingStarted>
