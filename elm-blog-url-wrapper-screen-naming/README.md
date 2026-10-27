# elm-blog-url-wrapper-screen-naming

The same app as `../elm-blog-url-wrapper`, with names changed only: `Page` is
`Screen` (what the app shows) and `Route` is `Destination` (where the app is).
With the thin URL wrapper the URL is no longer the source of truth, so a name
taken from URLs reads oddly: the model holds a screen, and the destination is
read from it (`destinationOf`). `Destination` is still the only module that
knows how a destination is spelled as a URL.

## Opaque types

Two opaque types make the wrong writes impossible to compile:

- `Guard.Guarded` (in `src/Guard.elm`): a destination that went through the
  guard. Only `Guard.guard` makes one.
- `CurrentScreen.CurrentScreen` (in `src/CurrentScreen.elm`): the screen shown, held in
  the model. Only `CurrentScreen.open`, which takes a `Guarded`, opens one; the
  only other change is to the form of the screen shown (`setLogin`,
  `setNewPost`).

Both modules expose the type without its constructor, with a reader
(`Guard.destination`, `CurrentScreen.screen`). `npm run check:opaque` compiles the modules
in `compile-fail/`: `Allowed.elm` compiles, and the ones that skip the guard,
write a screen into the model directly, or build either type by hand do not.

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

Other scripts: `npm run build`, `npm run preview`, `npm run format`, `npm run format:check`, `npm run check:opaque`.
