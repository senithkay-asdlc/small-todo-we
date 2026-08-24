// Todo app — single role, three screens

screen Login "User signs in via Thunder before seeing any todos"
  navbar "TodoApp"
  heading "Welcome to TodoApp"
  text "Sign in to see and manage your todos."
  button "Sign in" primary -> TodoList

screen TodoList "Signed-in user views their todos and creates new ones"
  navbar "TodoApp | My Todos -> TodoList"
  row
    heading "My Todos"
    right
    button "New Todo" primary -> NewTodo
  tabs "All (8) | Active (5) | Completed (3)"
  table "Todo | Status"
    row "Buy groceries | Open"
    row "Finish design doc | Open"
    row "Book dentist appointment | Open"
    row "Pay electricity bill | Done"
    row "Read chapter 4 | Done"

screen NewTodo "User captures a new task to track"
  navbar "TodoApp | My Todos -> TodoList"
  breadcrumb "My Todos / New Todo"
  heading "New Todo"
  input "What do you need to do?"
  row
    right
    button "Cancel" -> TodoList
    button "Save" primary -> TodoList

flow "Manage my todos"
  role "User"
  description "A user signs in, adds a task, and marks tasks complete"
  Login
  TodoList
  NewTodo
