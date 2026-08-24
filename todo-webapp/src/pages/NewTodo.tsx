import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { createTodo } from "../api";

export function NewTodo() {
  const navigate = useNavigate();
  const [text, setText] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSave() {
    const trimmed = text.trim();
    if (!trimmed) {
      setError("Enter what you need to do.");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await createTodo(trimmed);
      navigate("/");
    } catch {
      setError("Could not save this todo.");
      setSaving(false);
    }
  }

  return (
    <div>
      <nav>TodoApp | My Todos</nav>
      <p>My Todos / New Todo</p>
      <h1>New Todo</h1>
      <input
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="What do you need to do?"
        disabled={saving}
        autoFocus
      />
      {error && <p role="alert">{error}</p>}
      <div className="row">
        <button onClick={() => navigate("/")} disabled={saving}>
          Cancel
        </button>
        <button className="primary" onClick={() => void handleSave()} disabled={saving}>
          Save
        </button>
      </div>
    </div>
  );
}
