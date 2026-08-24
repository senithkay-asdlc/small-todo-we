import createClient from "openapi-fetch";
import type { paths, components } from "./generated/todo-api";
import { getAccessToken, signIn } from "./auth";

export type Todo = components["schemas"]["Todo"];
export type TodoPage = {
  count: number;
  next?: string | null;
  previous?: string | null;
  data: Todo[];
};

const client = createClient<paths>({ baseUrl: "/api" });

client.use({
  async onRequest({ request }) {
    const token = await getAccessToken();
    if (token) {
      request.headers.set("Authorization", `Bearer ${token}`);
    }
    return request;
  },
  async onResponse({ response }) {
    if (response.status === 401) {
      // Access token missing/expired past silent renewal — restart sign-in.
      await signIn();
    }
    return response;
  },
});

// `X-User-Id` is the caller identity the API GATEWAY injects from the
// validated bearer token (see api-management / thunder-authentication) — a
// client never sets it, and the gateway overwrites whatever arrives here
// before todo-api ever sees the request. The OpenAPI contract still marks the
// header required (it documents what the backend receives), so the generated
// client type requires a value here; this placeholder is inert.
const GATEWAY_INJECTED_USER_ID = "gateway-injected";

export async function listTodos(query?: {
  limit?: number;
  offset?: number;
  completed?: boolean;
}): Promise<TodoPage> {
  const { data, error } = await client.GET("/todos", {
    params: {
      header: { "X-User-Id": GATEWAY_INJECTED_USER_ID },
      query,
    },
  });
  if (error) throw error;
  return data;
}

export async function createTodo(text: string): Promise<Todo> {
  const { data, error } = await client.POST("/todos", {
    params: { header: { "X-User-Id": GATEWAY_INJECTED_USER_ID } },
    body: { text },
  });
  if (error) throw error;
  return data;
}

export async function completeTodo(todoId: string): Promise<Todo> {
  const { data, error } = await client.POST("/todos/{todoId}/complete", {
    params: {
      header: { "X-User-Id": GATEWAY_INJECTED_USER_ID },
      path: { todoId },
    },
  });
  if (error) throw error;
  return data;
}
