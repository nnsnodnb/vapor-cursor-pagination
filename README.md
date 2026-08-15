# vapor-cursor-pagination

`VaporCursorPagination` is a library for Vapor's Fluent that enables cursor-based pagination. Inspired by [Django REST Framework](https://github.com/encode/django-rest-framework).

## Requirements

- macOS 10.15 or later
- Vapor v4.0.0 or later
- FluentKit v1.48.6 or later

## Installation

`VaporCursorPagination` can be installed using [Swift Package Manager](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/). Add the following to your `Package.swift`.

```swift
let package = Package(
  dependencies: [
    .package(
      url: "https://github.com/nnsnodnb/vapor-cursor-pagination",
      from: "0.1.0",
    ),
  ],
  targets: [
    .target(
      name: "<your-target-name>",
      dependencies: [
        .product(name: "VaporCursorPagination", package: "vapor-cursor-pagination"),
      ],
    ),
  ],
)
```

## Usage

```swift
import VaporCursorPagination
```

Set up the route with `CursorPage<Model>` as the return type.  
To paginate the results, simply call `.cursorPaginate(...)` on your QueryBuilder.

```swift
routes.get("todos") { req -> CursorPage<Todo> in
  try await Todo.query(on: req.db)
    .cursorPaginate(
      for: req,
      sortedBy: \.$created,
      direction: .descending,
      tiebreaker: \.$id,
      defaultPageSize: 20,
      maxPageSize: 100,
    )
}
```

You can make a request to `http://127.0.0.1:8080/todos/`.

```bash
$ curl http://127.0.0.1:8080/todos/
```

```json
{
  "next": "eyJwIjoxNzg2NzczNjA3MTE0LjQyNywiciI6ZmFsc2UsInMiOiIzOURBRjE1Qy1BODUwLTQ2MDYtOEE3QS02RTcwOTkwNzk3OEIifQ",
  "items": [
    {
      "id": "1A035D63-C048-49AD-8A17-AA32CBCADD6D",
      "title": "Todo 24",
      "updatedAt": "2026-08-15T06:00:50Z",
      "createdAt": "2026-08-15T06:00:50Z"
    },
    {
      "id": "646760CE-1929-48C5-82EC-567FBC4AAC4C",
      "title": "Todo 23",
      "updatedAt": "2026-08-15T06:00:46Z",
      "createdAt": "2026-08-15T06:00:46Z"
    },
    ...
    {
      "id": "D0F85DF1-12A9-4401-8ED5-2CB87A5E4A17",
      "createdAt": "2026-08-15T06:00:10Z",
      "updatedAt": "2026-08-15T06:00:10Z",
      "title": "Todo 6"
    },
    {
      "id": "39DAF15C-A850-4606-8A7A-6E709907978B",
      "createdAt": "2026-08-15T06:00:07Z",
      "updatedAt": "2026-08-15T06:00:07Z",
      "title": "Todo 5"
    }
  ]
}
```

Then, you can use `next` value in your next context as `cursor` query parameter.

```bash
$ curl http://127.0.0.1:8080/todos/\?cursor\=eyJwIjoxNzg2NzczNjA3MTE0LjQyNywiciI6ZmFsc2UsInMiOiIzOURBRjE1Qy1BODUwLTQ2MDYtOEE3QS02RTcwOTkwNzk3OEIifQ
```

```json
{
  "items": [
    {
      "id": "E7B9918F-A8CA-4576-9F86-70019CF38FEE",
      "title": "Todo 4",
      "updatedAt": "2026-08-13T11:28:36Z",
      "createdAt": "2026-08-13T11:28:36Z"
    },
    {
      "id": "58CBFAE1-B53A-4B47-A7F6-73B74111CB8B",
      "title": "Todo 3",
      "updatedAt": "2026-08-13T11:22:21Z",
      "createdAt": "2026-08-13T11:22:21Z"
    },
    {
      "id": "40935F1B-D23E-4A73-916A-B30206EAC523",
      "title": "Todo 2",
      "updatedAt": "2026-08-13T11:21:16Z",
      "createdAt": "2026-08-13T11:21:16Z"
    },
    {
      "id": "971DBDF8-361A-4410-97B6-8B823FF213DF",
      "title": "Todo 1",
      "updatedAt": "2026-08-13T11:13:33Z",
      "createdAt": "2026-08-13T11:13:33Z"
    }
  ],
  "previous": "eyJwIjoxNzg2NjIwNTE2MzgwLjA0OSwiciI6dHJ1ZSwicyI6IkU3Qjk5MThGLUE4Q0EtNDU3Ni05Rjg2LTcwMDE5Q0YzOEZFRSJ9"
}
```

You can also retrieve the `previous` page by using previous as `cursor` query parameter.

```bash
$ curl http://127.0.0.1:8080/todos/?cursor=eyJwIjoxNzg2NjIwNTE2MzgwLjA0OSwiciI6dHJ1ZSwicyI6IkU3Qjk5MThGLUE4Q0EtNDU3Ni05Rjg2LTcwMDE5Q0YzOEZFRSJ9
```

If there are no more results on the next page, `next` is omitted. Likewise, if there are no more results on the `previous` page, previous is omitted.

## API

### `CursorPage`

Represents a single page of results returned by cursor pagination, including cursors for navigating between pages.

| Name | Type | Description |
| :--: | :--: | :---------- |
| items | `[Model]` | The items in the current page. |
| next | `String?` | The cursor for retrieving the next page, or `nil` if there is no next page. |
| previous | `String?` | The cursor for retrieving the previous page, or `nil` if there is no previous page. |

### `CursorPageRequest`

Represents the pagination parameters decoded from the query parameters of an HTTP request.

| Name | Type | Description |
| :--: | :--: | :---------- |
| cursor | `String?` | The cursor used to determine the position of the page to retrieve. |
| size | `Int?` | The number of items to return per page. |

### `QueryBuilder.cursorPaginate(for:sortedBy:direction:tiebreaker:defaultPageSize:maxPageSize:)`

| Name | Type | Default | Description |
| :--: | :--: | :-----: | :---------- |
| for | `Request` |  | Vapor `Request` object for the current route. |
| sortedBy | `KeyPath<Model, QueryableProperty>` |  | Set the primary sort key. A time-based key such as `created` is recommended. |
| direction | `CursorPaginationDirection` | `.descending` | The sort direction. |
| tiebreaker | `KeyPath<Model, QueryableProperty>` |  | The key used to break ties when multiple records have the same value for the primary sort key. |
| defaultPageSize | `Int` | 20 | The default number of records returned per page. |
| maxPageSize | `Int` | 100 | The maximum number of records that can be returned per page. |

## License

VaporCursorPagination is available under the Apache-2.0 license. See the LICENSE file for more info.
