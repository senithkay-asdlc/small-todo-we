import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { completeTodo, listTodos, type Todo } from "../api";

type Filter = "all" | "active" | "completed";

// The todo-api page size caps at 100 (see openapi.yaml); this app has no
// pagination UI, so a single page covers the counts and the visible list.
const PAGE_SIZE = 100;

export function TodoList() {
  const navigate = useNavigate();
  const [todos, setTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState<Filter>("all");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const page = await listTodos({ limit: PAGE_SIZE });
      setTodos(page.data);
    } catch {
      setError("Could not load your todos.");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const counts = useMemo(
    () => ({
      all: todos.length,
      active: todos.filter((t) => !t.completed).length,
      completed: todos.filter((t) => t.completed).length,
    }),
    [todos],
  );

  const visible = useMemo(() => {
    switch (filter) {
      case "active":
        return todos.filter((t) => !t.completed);
      case "completed":
        return todos.filter((t) => t.completed);
      default:
        return todos;
    }
  }, [todos, filter]);

  async function handleComplete(id: string) {
    try {
      await completeTodo(id);
      await refresh();
    } catch {
      setError("Could not mark that todo complete.");
    }
  }

  return (
    <div>
      <nav>TodoApp | My Todos</nav>
      <div className="row">
        <h1>My Todos</h1>
        <button className="primary" onClick={() => navigate("/new")}>
          New Todo
        </button>
      </div>
      <div className="tabs" role="tablist">
        <button
          role="tab"
          aria-selected={filter === "all"}
          disabled={filter === "all"}
          onClick={() => setFilter("all")}
        >
          All ({counts.all})
        </button>
        <button
          role="tab"
          aria-selected={filter === "active"}
          disabled={filter === "active"}
          onClick={() => setFilter("active")}
        >
          Active ({counts.active})
        </button>
        <button
          role="tab"
          aria-selected={filter === "completed"}
          disabled={filter === "completed"}
          onClick={() => setFilter("completed")}
        >
          Completed ({counts.completed})
        </button>
      </div>

      {loading && <p>Loading…</p>}
      {error && <p role="alert">{error}</p>}

      {!loading && !error && (
        <table>
          <thead>
            <tr>
              <th>Todo</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {visible.map((todo) => (
              <tr key={todo.id} className={todo.completed ? "completed" : undefined}>
                <td>{todo.text}</td>
                <td>
                  {todo.completed ? (
                    <span aria-label="Done">Done</span>
                  ) : (
                    <button onClick={() => void handleComplete(todo.id)}>
                      Mark complete
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {visible.length === 0 && (
              <tr>
                <td colSpan={2}>Nothing here yet.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
