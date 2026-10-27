module Guard exposing (Guarded, guard, route)

{-| A destination that went through the guard. Only `guard` makes one, and
everything that opens a destination takes a `Guarded`, so no move can skip the
guard.
-}

import Route exposing (Route)


type Guarded
    = Guarded (Maybe Route)


{-| Signed out the new post page redirects to the login page, signed in the
login page redirects home.
-}
guard : Maybe String -> Maybe Route -> Guarded
guard user maybeRoute =
    Guarded
        (case maybeRoute of
            Just Route.Login ->
                if user /= Nothing then
                    Just Route.Home

                else
                    maybeRoute

            Just Route.NewPost ->
                if user == Nothing then
                    Just Route.Login

                else
                    maybeRoute

            _ ->
                maybeRoute
        )


route : Guarded -> Maybe Route
route (Guarded maybeRoute) =
    maybeRoute
