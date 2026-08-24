import { signIn } from "../auth";

export function Login() {
  return (
    <div>
      <nav>TodoApp</nav>
      <h1>Welcome to TodoApp</h1>
      <p>Sign in to see and manage your todos.</p>
      <button onClick={() => void signIn()}>Sign in</button>
    </div>
  );
}
