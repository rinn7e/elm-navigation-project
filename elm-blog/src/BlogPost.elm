module BlogPost exposing (BlogPost, all, find, slugify)

-- The posts of the blog, hard-coded (there is no server)


type alias BlogPost =
    { slug : String
    , title : String
    , date : String
    , body : List String
    }


all : List BlogPost
all =
    [ { slug = "hello-elm"
      , title = "Hello Elm"
      , date = "2026-01-12"
      , body =
            [ "Elm is a small functional language that compiles to JavaScript."
            , "Every app has the same shape: a model, a view of the model, and an update that turns a message into a new model."
            ]
      }
    , { slug = "tailwind-with-vite"
      , title = "Tailwind with Vite"
      , date = "2026-02-03"
      , body =
            [ "Tailwind v4 has a Vite plugin, so the setup is one import in the CSS file."
            , "It scans the project for class names, Elm files included."
            ]
      }
    , { slug = "the-url-is-not-state"
      , title = "The URL is not state"
      , date = "2026-03-21"
      , body =
            [ "The address bar shows where the app is, the same way the view shows what the app holds."
            , "Both can be read from the model."
            ]
      }
    ]


find : String -> List BlogPost -> Maybe BlogPost
find slug posts =
    List.filter (\post -> post.slug == slug) posts
        |> List.head


slugify : String -> String
slugify title =
    title
        |> String.toLower
        |> String.map
            (\char ->
                if Char.isAlphaNum char then
                    char

                else
                    '-'
            )
        |> String.split "-"
        |> List.filter (not << String.isEmpty)
        |> String.join "-"
