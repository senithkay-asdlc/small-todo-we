# small-todo-we — Design

## Overview

A small todo app: a single React single-page app (`todo-webapp`) lets a
signed-in User create todos, view their own list, and mark todos complete. It
talks to one Ballerina backend (`todo-api`), which persists todos in a
dedicated Postgres database (`todo-db`) and validates the caller's identity
against Thunder, the platform identity provider, so a user only ever sees
their own todos.

## Context (C1)

```mermaid
graph TD
    User((User))
    subgraph System["small-todo-we"]
        Webapp[todo-webapp]
        Api[todo-api]
        Db[(todo-db)]
    end
    Thunder[["Thunder Auth"]]

    User -->|signs in, manages todos| Webapp
    Webapp -->|REST calls| Api
    Api -->|reads/writes| Db
    Webapp -.->|OIDC sign-in| Thunder
    Api -.->|validates token| Thunder
```

## Domain model (ER)

```mermaid
erDiagram
    TODO {
        string id PK
        string userId
        string text
        boolean completed
        datetime createdAt
    }
```

A `Todo` belongs to exactly one User (`userId`, from the Thunder-validated
token) — no other entity is required for this scope.

## Key flows

### Create and save a todo

```mermaid
sequenceDiagram
    actor User
    participant Webapp as todo-webapp
    participant Api as todo-api
    participant Db as todo-db

    User->>Webapp: Enter todo text, submit
    Webapp->>Api: POST /todos (Bearer token)
    Api->>Api: Validate token, resolve userId
    Api->>Db: INSERT todo (userId, text, completed=false)
    Db-->>Api: Todo saved
    Api-->>Webapp: 201 Created (todo)
    Webapp-->>User: Todo appears in list
```

### View and complete a todo

```mermaid
sequenceDiagram
    actor User
    participant Webapp as todo-webapp
    participant Api as todo-api
    participant Db as todo-db

    User->>Webapp: Open todo list
    Webapp->>Api: GET /todos (Bearer token)
    Api->>Db: SELECT todos WHERE userId = caller
    Db-->>Api: User's todos
    Api-->>Webapp: 200 OK (todos)
    Webapp-->>User: List rendered

    User->>Webapp: Mark a todo complete
    Webapp->>Api: POST /todos/{id}/complete (Bearer token)
    Api->>Db: UPDATE todo SET completed=true WHERE id AND userId=caller
    Db-->>Api: Updated
    Api-->>Webapp: 200 OK (todo)
    Webapp-->>User: Todo shown as complete
```