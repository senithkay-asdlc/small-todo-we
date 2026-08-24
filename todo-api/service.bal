import ballerina/http;

listener http:Listener ep0 = new (9090);

const int MAX_LIMIT = 100;
const int DEFAULT_LIMIT = 20;

# Resolves the caller's identity from the gateway-injected header.
# Returns an ErrorUnauthorized when it is missing or blank.
function resolveUserId(string? headerValue) returns string|ErrorUnauthorized {
    if headerValue is string {
        string trimmed = headerValue.trim();
        if trimmed.length() > 0 {
            return trimmed;
        }
    }
    return <ErrorUnauthorized>{
        body: {code: 401, message: "unauthorized", description: "Missing or invalid X-User-Id"}
    };
}

function clamp(int 'limit, int offset) returns [int, int] {
    int boundedLimit = 'limit;
    if boundedLimit < 1 {
        boundedLimit = DEFAULT_LIMIT;
    } else if boundedLimit > MAX_LIMIT {
        boundedLimit = MAX_LIMIT;
    }
    int boundedOffset = offset;
    if boundedOffset < 0 {
        boundedOffset = 0;
    }
    return [boundedLimit, boundedOffset];
}

function pageUri(int 'limit, int offset, boolean? completed) returns string {
    string uri = string `/todos?limit=${'limit}&offset=${offset}`;
    if completed is boolean {
        uri = uri + "&completed=" + completed.toString();
    }
    return uri;
}

service / on ep0 {
    # List the caller's todos
    #
    # + x\-user\-id - caller identity injected by the gateway from the validated token
    # + completed - Filter by complete/incomplete status
    # + return - the caller's page of todos, or an auth error
    resource function get todos(@http:Header string? x\-user\-id, boolean? completed, int 'limit = 20, int offset = 0)
            returns TodoListOk|ErrorUnauthorized|error {
        string|ErrorUnauthorized userId = resolveUserId(x\-user\-id);
        if userId is ErrorUnauthorized {
            return userId;
        }

        [int, int] [boundedLimit, boundedOffset] = clamp('limit, offset);
        [Todo[], int] [todos, total] = check listOwnedTodos(userId, completed, boundedLimit, boundedOffset);

        string? next = ();
        if boundedOffset + boundedLimit < total {
            next = pageUri(boundedLimit, boundedOffset + boundedLimit, completed);
        }
        string? previous = ();
        if boundedOffset > 0 {
            int previousOffset = boundedOffset - boundedLimit;
            if previousOffset < 0 {
                previousOffset = 0;
            }
            previous = pageUri(boundedLimit, previousOffset, completed);
        }

        TodoPage page = {count: total, next: next, previous: previous, data: todos};
        return <TodoListOk>{body: page};
    }

    # Create a new todo for the caller
    #
    # + x\-user\-id - caller identity injected by the gateway from the validated token
    # + payload - the new todo's text
    # + return - the created todo, a validation error, or an auth error
    resource function post todos(@http:Header string? x\-user\-id, @http:Payload NewTodo payload)
            returns TodoCreated|ErrorBadRequest|ErrorUnauthorized|error {
        string|ErrorUnauthorized userId = resolveUserId(x\-user\-id);
        if userId is ErrorUnauthorized {
            return userId;
        }

        string text = payload.text.trim();
        if text.length() == 0 {
            return <ErrorBadRequest>{
                body: {code: 400, message: "bad request", description: "text is required"}
            };
        }

        Todo created = check insertTodo(userId, text);
        return <TodoCreated>{body: created};
    }

    # Mark the caller's todo as complete
    #
    # + x\-user\-id - caller identity injected by the gateway from the validated token
    # + todoId - the todo to complete
    # + return - the completed todo, a not-found error, or an auth error
    resource function post todos/[string todoId]/complete(@http:Header string? x\-user\-id)
            returns TodoOk|ErrorUnauthorized|ErrorNotFound|error {
        string|ErrorUnauthorized userId = resolveUserId(x\-user\-id);
        if userId is ErrorUnauthorized {
            return userId;
        }

        Todo? completedTodo = check completeOwnedTodo(todoId, userId);
        if completedTodo is () {
            return <ErrorNotFound>{
                body: {code: 404, message: "not found", description: "No such todo for this caller"}
            };
        }
        return <TodoOk>{body: completedTodo};
    }
}
