# Select/menu for Elm

Yet another implementation of select/menu component. This one is based on two principles:
- use the browser focus capablities
- don't store the lists (that can be long sometimes)

This allows to make the library pretty small (~200 lines of code currently).

This module handles:
- list of links causing redirection when selected - menu mode
- list of buttons carring value - select mode

There's a keyboard managment included: up/down navigation, escape hides dropdown, enter selects.


## Example

Simple usage:

```elm
import Html exposing (Html, div, button, text)
import Menu exposing (Menu)


type alias Model =
    {menu: Menu}


type Msg 
    = MenuMsg Menu.Msg
    | Selected String


-- Simple dropdown menu

simpleMenu: Model -> Html msg
simpleMenu { menu } =
    div [ ]
        [ button (Menu.trigger MenuMsg menu) [ text "Videos" ]
        , Menu.view menu [ class "mt-0 sm:mt-4" ] 
            [ Menu.link "/#popular" [] [ text "Popular" ]
            , Menu.link "/#viewed" [] [ text "Most viewed" ]
            , Menu.link "/#rated" [] [ text "Best rated" ]
            ]
            |> Html.map MenuMsg
        ]


-- Select behaviour

simpleSelect: Model -> Html msg
simpleSelect { menu } =
    div [ Menu.onSelect Selected menu ]
        [ button (Menu.trigger MenuMsg menu) [ text "What's your breakfast type?" ]
        , Menu.view menu []
            [ Menu.button "C" [] [ text "Continental" ]
            , Menu.button "E" [] [ text "English" ]
            , Menu.button "A" [] [ text "American" ]
            ]
        ]
```