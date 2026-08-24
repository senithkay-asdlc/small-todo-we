import { BrowserRouter, Route, Routes } from "react-router-dom";
import { AuthGate } from "./AuthGate";
import { Callback } from "./pages/Callback";
import { NewTodo } from "./pages/NewTodo";
import { TodoList } from "./pages/TodoList";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/callback" element={<Callback />} />
        <Route element={<AuthGate />}>
          <Route path="/" element={<TodoList />} />
          <Route path="/new" element={<NewTodo />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
