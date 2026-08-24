import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { handleCallback } from "../auth";

// The Thunder OIDC redirect target. Runs `handleCallback()` once on mount,
// per thunder-authentication's SPA flow, then returns to the app root.
export function Callback() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const ran = useRef(false);

  useEffect(() => {
    if (ran.current) return;
    ran.current = true;
    handleCallback()
      .then(() => navigate("/", { replace: true }))
      .catch((err) => setError(err instanceof Error ? err.message : String(err)));
  }, [navigate]);

  if (error) {
    return <p role="alert">Sign-in failed: {error}</p>;
  }
  return <p>Signing you in…</p>;
}
