# small-todo-we — PRD

## Problem Statement

People juggling daily tasks lose track of what they need to do because sticky
notes and memory don't persist across devices or sessions. They need a simple,
personal place to record tasks and see at a glance what's still open and what's
done.

## Solution

A small web app where a user signs in, creates todo items, saves them to a
database, and can see their list of todos and mark any of them as complete.

## Actors

- **User** — signs in to the app, creates todos, views their own list of
todos, and marks todos as complete.

## User Stories

1. As a User, I want to sign in, so that my todos are kept private to me.
2. As a User, I want to create a todo item, so that I can capture a task I
need to do.
3. As a User, I want my created todo to be saved, so that it's not lost when I
close or reload the app.
4. As a User, I want to see the list of todos I've created, so that I know
what I still need to do.
5. As a User, I want to mark a todo as complete, so that I can track my
progress and see what's done.

## Product Decisions

- Sign-in is via SSO through Thunder, the platform identity provider (org
default).
- Each User only ever sees and manages their own todos — one user's list is
never visible to another.
- A todo has just a short text description and a complete/incomplete status —
no due date, priority, or category in this version.
- Once created, a todo's text cannot be edited or deleted — the only state
change is marking it complete.

## Out of Scope

- Editing or deleting a todo once created.
- Due dates, reminders, priorities, or categories/tags on todos.
- Sharing or collaborating on todos between users.
- Any notification channel (email, push, etc.).

## Open Questions

(none currently — all decisions above were either organization defaults or
reasonable assumptions flagged for the user to confirm or override)