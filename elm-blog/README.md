# elm-blog

A small blog in Elm, with navigation done the usual way (as in
[elm-spa-example](https://github.com/rtfeldman/elm-spa-example)):
`Browser.application`, a `Route` type parsed with `Url.Parser`, a `Page` in the
model, `onUrlRequest` / `onUrlChange`, and `Nav.pushUrl` / `Nav.replaceUrl`
called from `update`. The URL is the source of truth: every move goes through
the URL and comes back as `UrlChanged`.

## Opaque types

Two opaque types make the wrong writes impossible to compile:

- `Guard.Guarded` (in `src/Guard.elm`): a destination that went through the
  guard. Only `Guard.guard` makes one.
- `CurrentPage.CurrentPage` (in `src/CurrentPage.elm`): the page shown, held in
  the model. Only `CurrentPage.open`, which takes a `Guarded`, opens one; the
  only other change is to the form of the page shown (`setLogin`,
  `setNewPost`).

Both modules expose the type without its constructor, with a reader
(`Guard.route`, `CurrentPage.page`). `npm run check:opaque` compiles the modules
in `compile-fail/`: `Allowed.elm` compiles, and the ones that skip the guard,
write a page into the model directly, or build either type by hand do not.

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
