import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

final int dbPortNumber = check int:fromString(dbPort);

final postgresql:Client dbClient = check new (
    host = dbHost,
    port = dbPortNumber,
    database = dbName,
    username = dbUser,
    password = dbPassword
);

function init() returns error? {
    _ = check dbClient->execute(`
        CREATE TABLE IF NOT EXISTS todos (
            id VARCHAR(64) PRIMARY KEY,
            user_id VARCHAR(128) NOT NULL,
            text TEXT NOT NULL,
            completed BOOLEAN NOT NULL DEFAULT FALSE,
            created_at TIMESTAMPTZ NOT NULL
        )
    `);
}
