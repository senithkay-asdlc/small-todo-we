import ballerina/os;

// todo-db (platform-resource, postgres-cnpg) — envBindings from design.json, verbatim.
configurable string dbHost = os:getEnv("TODO_DB_HOST");
configurable string dbPort = os:getEnv("TODO_DB_PORT");
configurable string dbName = os:getEnv("TODO_DB_DBNAME");
configurable string dbUser = os:getEnv("TODO_DB_USER");
configurable string dbPassword = os:getEnv("TODO_DB_PASSWORD");

// user-auth (platform-resource, thunder-app) — envBindings from design.json, verbatim.
// The gateway validates the caller's token and injects X-User-Id; this service
// never validates a JWT itself. These are read only for wiring/documentation
// completeness, per the platform-resource contract.
configurable string userAuthClientId = os:getEnv("USER_AUTH_CLIENT_ID");
configurable string userAuthIssuer = os:getEnv("USER_AUTH_ISSUER");
configurable string userAuthJwksUrl = os:getEnv("USER_AUTH_JWKS_URL");
configurable string userAuthScopes = os:getEnv("USER_AUTH_SCOPES");
