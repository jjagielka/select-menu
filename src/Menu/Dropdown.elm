module Menu.Dropdown exposing
    ( Dropdown
    , open, closed
    , view
    , trigger
    )

{-| Probably the simplest implementation of the dropdown.


# Types

@docs Dropdown


# Operations


## Creation

@docs open, closed


## View

@docs view


## Control

@docs trigger

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, style, tabindex)
import Html.Events exposing (keyCode, on, onBlur, onClick, onFocus, onMouseDown)
import Json.Decode as Decode


type State
    = Open
    | Closed


{-| Dropdown model type.
-}
type Dropdown
    = Dropdown State


{-| Creates a closed dropdown.
-}
closed : Dropdown
closed =
    Dropdown Closed


{-| Creates an open dropdown.
-}
open : Dropdown
open =
    Dropdown Open


{-| Toggles the dropdown state: closed/open.
-}
toggle : Dropdown -> Dropdown
toggle (Dropdown drop) =
    case drop of
        Closed ->
            open

        Open ->
            closed


{-| View
-}
view : (Dropdown -> msg) -> Dropdown -> List (Attribute msg) -> List (Html msg) -> Html msg
view toMsg (Dropdown drop) attrs children =
    if drop == Open && not (List.isEmpty children) then
        div [ class "drop", style "position" "relative", style "display" "inline-block", onFocusOut <| toMsg closed, onFocusIn <| toMsg open ]
            [ div (style "position" "absolute" :: style "overflow-y" "auto" :: tabindex -1 :: attrs) children ]

    else
        text ""


{-| This should be attached to the element that will control dropdown opening (button, input for search, ...)
-}
trigger : (Dropdown -> msg) -> Dropdown -> List (Attribute msg)
trigger toMsg drop =
    [ onMouseDown <| toMsg (toggle drop)
    , onFocus <| toMsg (toggle drop)
    , onBlur <| toMsg closed
    ]



-- Events


onFocusIn : msg -> Attribute msg
onFocusIn toMsg =
    on "focusin" (Decode.succeed toMsg)


onFocusOut : msg -> Attribute msg
onFocusOut toMsg =
    on "focusout" (Decode.succeed toMsg)
