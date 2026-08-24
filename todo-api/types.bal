import ballerina/http;
import ballerina/time;

# A single todo item as returned to a caller.
public type Todo record {|
    string id;
    string text;
    boolean completed;
    string createdAt;
|};

# Payload to create a new todo.
public type NewTodo record {|
    string text;
|};

# Shared error shape for every 4xx response.
public type Error record {|
    int code;
    string message;
    string description?;
    string moreInfo?;
|};

# Paginated envelope returned by GET /todos.
public type TodoPage record {|
    int count;
    string? next;
    string? previous;
    Todo[] data;
|};

public type TodoListOk record {|
    *http:Ok;
    TodoPage body;
|};

public type TodoCreated record {|
    *http:Created;
    Todo body;
|};

public type TodoOk record {|
    *http:Ok;
    Todo body;
|};

public type ErrorBadRequest record {|
    *http:BadRequest;
    Error body;
|};

public type ErrorUnauthorized record {|
    *http:Unauthorized;
    Error body;
|};

public type ErrorNotFound record {|
    *http:NotFound;
    Error body;
|};

# A single row read back from the `todos` table.
type TodoRow record {|
    string id;
    string userId;
    string text;
    boolean completed;
    time:Utc createdAt;
|};

type CountRow record {|
    int count;
|};
