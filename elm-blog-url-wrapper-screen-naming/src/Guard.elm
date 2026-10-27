module Guard exposing (Guarded, destination, guard)

{-| A destination that went through the guard. Only `guard` makes one, and
everything that opens a destination takes a `Guarded`, so no move can skip the
guard.
-}

import Destination exposing (Destination)


type Guarded
    = Guarded (Maybe Destination)


{-| Signed out the new post screen redirects to the login screen, signed in the
login screen redirects home.
-}
guard : Maybe String -> Maybe Destination -> Guarded
guard user maybeDestination =
    Guarded
        (case maybeDestination of
            Just Destination.Login ->
                if user /= Nothing then
                    Just Destination.Home

                else
                    maybeDestination

            Just Destination.NewPost ->
                if user == Nothing then
                    Just Destination.Login

                else
                    maybeDestination

            _ ->
                maybeDestination
        )


destination : Guarded -> Maybe Destination
destination (Guarded maybeDestination) =
    maybeDestination
