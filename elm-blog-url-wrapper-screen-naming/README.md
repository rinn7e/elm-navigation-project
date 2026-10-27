# elm-blog-url-wrapper-screen-naming

The same app as `../elm-blog-url-wrapper`, with names changed only: `Page` is
`Screen` (what the app shows) and `Route` is `Destination` (where the app is).
With the thin URL wrapper the URL is no longer the source of truth, so a name
taken from URLs reads oddly: the model holds a screen, and the destination is
read from it (`destinationOf`). `Destination` is still the only module that
knows how a destination is spelled as a URL.

## Pages

- `/`: the list of posts
- `/post/<slug>`: one post
- `/about`: about
- `/login`: login, with the test account below
- `/new`: write a new post, for signed-in users only

The guard: signed out, `/new` redirects to `/login`; signed in, `/login`
redirects to `/`.

## Test account

- Username: `test`
- Password: `testtest`

The signed-in user is kept in `localStorage`, so a refresh keeps it. The posts
are hard-coded in `src/BlogPost.elm` (there is no server); a new post is kept in
memory until the page reloads.

## Run

Every tool (Elm, elm-format, Vite, Tailwind) is a local dev dependency.

```bash
npm install
npm run dev
```

Other scripts: `npm run build`, `npm run preview`, `npm run format`.
