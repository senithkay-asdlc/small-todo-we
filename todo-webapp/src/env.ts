// Typed shim over the platform-mounted `window._env_`. Populated at request
// time by `/env-config.js` — never at build time (no `import.meta.env.VITE_*`).
type Env = {
  // user-auth (thunder-app platform-resource) — OIDC config for the browser.
  USER_AUTH_CLIENT_ID: string;
  USER_AUTH_ISSUER: string;
  USER_AUTH_JWKS_URL: string;
  USER_AUTH_SCOPES: string;
};

declare global {
  interface Window {
    _env_: Env;
  }
}

if (!window._env_) {
  throw new Error(
    "window._env_ not set — /env-config.js failed to load. " +
      "The platform mounts this file; if you see this locally, host " +
      "/env-config.js from your dev server.",
  );
}

export const env: Env = window._env_;
