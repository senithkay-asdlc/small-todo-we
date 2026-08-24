import { useEffect, useState } from "react";
import { Outlet } from "react-router-dom";
import { currentUser } from "./auth";
import { Login } from "./pages/Login";

type Status = "checking" | "authed" | "anon";

// Gates every route beneath it on `currentUser()`: a signed-in visitor
// proceeds to the app, an unauthenticated one sees Login instead — never the
// todo list. Do not call signIn() just because this check runs; Login's own
// button starts the redirect.
export function AuthGate() {
  const [status, setStatus] = useState<Status>("checking");

  useEffect(() => {
    let cancelled = false;
    void currentUser().then((user) => {
      if (!cancelled) setStatus(user ? "authed" : "anon");
    });
    return () => {
      cancelled = true;
    };
  }, []);

  if (status === "checking") return <p>Loading…</p>;
  if (status === "anon") return <Login />;
  return <Outlet />;
}
