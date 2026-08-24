# small-todo-we — Security

## Roles → permissions

There is no admin or shared role — the PRD defines a single actor, User, and
every User has identical permissions scoped to their own data.

## Authentication (Thunder)

- Shared `thunder-app` dependency name: **`user-auth`**, declared identically
on `todo-webapp` and `todo-api` — the shared name is what ties browser
sign-in to the bearer tokens `todo-api` validates.
- Scopes: `openid profile email` (default).
- `todo-webapp` sits in front of sign-in: it runs the OIDC + PKCE flow in the
browser and attaches the resulting token to every call to `todo-api`.
- `todo-api` sits behind sign-in: every endpoint requires a valid bearer
token; there are no public/unauthenticated endpoints on this service.

## Role resolution

`todo-api` resolves the caller's identity from the validated token's subject
claim (injected by the gateway, e.g. `X-User-Id`) and uses it as the `userId`
that scopes every read and write — a todo is only ever visible to, or
modifiable by, the user who owns it. A request with no valid token is
rejected with `401`; a request for another user's todo is rejected with `404`
(never revealing that the record exists under a different owner).