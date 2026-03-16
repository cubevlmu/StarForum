# StarForum Architecture

StarForum follows a layered architecture to keep the codebase maintainable and scalable.

## Layers

### API Layer

Responsible for communicating with the Flarum backend API.

Responsibilities:

- HTTP requests
- Response parsing
- Error handling

---

### Repository Layer

Acts as a bridge between the API layer and the UI.

Responsibilities:

- Data transformation
- Caching
- Business logic

---

### UI Layer

Responsible for rendering the user interface.

Examples:

- Discussion list
- Discussion detail page
- User profile page

---

### Controller / State Layer

Handles state management and interaction between UI and repositories.

Responsibilities:

- State updates
- Event handling
- UI refresh triggers

---

## Design Principles

### Separation of concerns

Each layer has a clear responsibility.

### Modularity

UI components are reusable and modular.

### Extensibility

The architecture allows future support for additional Flarum extensions and features.