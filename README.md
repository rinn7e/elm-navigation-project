# elm-navigation-project

Three versions of the same small Elm blog (post list, post, about, login, and a
new post page for signed-in users), to compare two ways of handling navigation.

1. `elm-blog/`: the usual Elm way, as in elm-spa-example. The URL is the source
   of truth: `update` calls `Nav.pushUrl` / `Nav.replaceUrl`, and every move
   comes back as `UrlChanged`.
2. `elm-blog-url-wrapper/`: the thin URL wrapper. The model owns where the app
   is, `update` never touches the URL, and one wrapper around the root `update`
   writes it after every step. Only the navigation code differs from
   `elm-blog/`.
3. `elm-blog-url-wrapper-screen-naming/`: the same as `elm-blog-url-wrapper/`
   with names changed only (`Page` is `Screen`, `Route` is `Destination`).

Each app runs on its own:

```bash
cd elm-blog
npm install
npm run dev
```

Test account: username `test`, password `testtest`.

To compare the versions:

```bash
git diff --no-index elm-blog/src elm-blog-url-wrapper/src
git diff --no-index elm-blog-url-wrapper/src elm-blog-url-wrapper-screen-naming/src
```
