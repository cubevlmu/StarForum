# Flarum data-layer acceptance

This checklist must be completed against real servers before freezing the data
layer. Source fixtures are not a replacement for live-server verification.

| Feature | Flarum 1.x | Flarum 2.x | Notes |
| --- | --- | --- | --- |
| Forum info | Pending | Pending | `GET /api` |
| Login | Pending | Pending | Raw access token from `POST /api/token` |
| Restart authentication restore | Pending | Pending | Token must remain site-scoped |
| Discussion list | Pending | Pending | Explicit fields/includes |
| Discussion detail | Pending | Pending | Must not require `posts` |
| Posts pagination | Pending | Pending | Independent `/api/posts`, follow `links.next` |
| Pull-to-refresh | Pending | Pending | First-page cache invalidation |
| Reply | Pending | Pending | JSON:API request body |
| Like/unlike | Pending | Pending | `PATCH /api/posts/{id}` |
| Follow/unfollow | Pending | Pending | `PATCH /api/discussions/{id}` |
| User profile | Pending | Pending | `avatarSrcset` is optional |
| Notifications | Pending | Pending | Unknown extension subjects remain visible |
| Logout | Pending | Pending | 404/405 falls back to local logout |
| FoF Upload absent | Pending | Pending | Returns `extensionUnavailable` |
| Badge extension absent | Pending | Pending | Returns `extensionUnavailable` |
| Expired token | Pending | Pending | Maps to `tokenExpired` |
| Switch forum | Pending | Pending | Cache and token must not cross sites |

## Required live sequence

1. Cold-start forum setup.
2. Browse discussions while logged out.
3. Login and verify the `Authorization: Token <token>` request header.
4. Restart the application and verify authentication restoration.
5. Open a discussion whose show response does not include posts.
6. Load first and subsequent post pages through `/api/posts`.
7. Refresh and paginate discussion, post, and notification lists.
8. Create a discussion, reply, like, and follow.
9. Load the current user and notifications.
10. Logout, including a server without a supported logout endpoint.
