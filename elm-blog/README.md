# elm-blog

A small blog in Elm, with navigation done the usual way (as in
[elm-spa-example](https://github.com/rtfeldman/elm-spa-example)):
`Browser.application`, a `Route` type parsed with `Url.Parser`, a `Page` in the
model, `onUrlRequest` / `onUrlChange`, and `Nav.pushUrl` / `Nav.replaceUrl`
called from `update`. The URL is the source of truth: every move goes through
the URL and comes back as `UrlChanged`.

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
