import ballerina/sql;
import ballerina/time;
import ballerina/uuid;

const string SELECT_COLUMNS = "id, user_id AS \"userId\", text, completed, created_at AS \"createdAt\"";

function toTodo(TodoRow row) returns Todo => {
    id: row.id,
    text: row.text,
    completed: row.completed,
    createdAt: time:utcToString(row.createdAt)
};

function ownerFilter(string userId, boolean? completed) returns sql:ParameterizedQuery {
    sql:ParameterizedQuery filter = `user_id = ${userId}`;
    if completed is boolean {
        filter = sql:queryConcat(filter, ` AND completed = ${completed}`);
    }
    return filter;
}

# Inserts a new todo for `userId` and returns the stored record.
function insertTodo(string userId, string text) returns Todo|error {
    string id = uuid:createType1AsString();
    time:Utc createdAtUtc = time:utcNow();
    sql:ParameterizedQuery query = `INSERT INTO todos (id, user_id, text, completed, created_at)
        VALUES (${id}, ${userId}, ${text}, FALSE, ${new sql:TimestampValue(createdAtUtc)})`;
    _ = check dbClient->execute(query);
    return {
        id: id,
        text: text,
        completed: false,
        createdAt: time:utcToString(createdAtUtc)
    };
}

# Returns a page of `userId`'s todos plus the total count matching `completed`.
function listOwnedTodos(string userId, boolean? completed, int 'limit, int offset) returns [Todo[], int]|error {
    sql:ParameterizedQuery filter = ownerFilter(userId, completed);

    sql:ParameterizedQuery countQuery = sql:queryConcat(`SELECT COUNT(*) AS "count" FROM todos WHERE `, filter);
    CountRow countRow = check dbClient->queryRow(countQuery);

    sql:ParameterizedQuery dataQuery = sql:queryConcat(
        `SELECT ${SELECT_COLUMNS} FROM todos WHERE `,
        filter,
        ` ORDER BY created_at ASC, id ASC LIMIT ${'limit} OFFSET ${offset}`
    );
    stream<TodoRow, sql:Error?> rows = dbClient->query(dataQuery);
    Todo[] todos = [];
    check from TodoRow row in rows
        do {
            todos.push(toTodo(row));
        };
    check rows.close();

    return [todos, countRow.count];
}

# Looks up a todo owned by `userId`. Returns () when no such todo exists for this caller.
function findOwnedTodo(string todoId, string userId) returns Todo?|error {
    sql:ParameterizedQuery query = `SELECT ${SELECT_COLUMNS} FROM todos WHERE id = ${todoId} AND user_id = ${userId}`;
    TodoRow|error row = dbClient->queryRow(query);
    if row is sql:NoRowsError {
        return ();
    }
    if row is error {
        return row;
    }
    return toTodo(row);
}

# Marks `todoId` complete for `userId`. Returns () when no such todo exists for this caller.
function completeOwnedTodo(string todoId, string userId) returns Todo?|error {
    Todo? existing = check findOwnedTodo(todoId, userId);
    if existing is () {
        return ();
    }
    sql:ParameterizedQuery query = `UPDATE todos SET completed = TRUE WHERE id = ${todoId} AND user_id = ${userId}`;
    _ = check dbClient->execute(query);
    existing.completed = true;
    return existing;
}
