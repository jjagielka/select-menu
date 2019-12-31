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

To see live example go to the [example](http://jjagielka.github.io/select-menu) page and be sure to check out the [example code](https://github.com/jjagielka/select-menu/tree/master/examples) to get a better idea on how the configs work.


```elm
import Html exposing (Html, div, button, text)
import Menu exposing (Menu)


type alias Model =
    {menu: Menu}


init : Model
init =
    {menu = Menu.init "unique-identifier"}


type Msg 
    = MenuMsg Menu.Msg
    | Selected String


-- Use it as dropdown menu with html links

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

-- .. or use it as a select with Selected messsage

simpleSelect: Model -> Html msg
simpleSelect { menu } =
    div [ Menu.onSelect Selected menu ]
        [ button (Menu.trigger MenuMsg menu) 
            [ text "What's your breakfast type?" 
            ]
        , Menu.view menu []
            [ Menu.button "C" [] [ text "Continental" ]
            , Menu.button "E" [] [ text "English" ]
            , Menu.button "A" [] [ text "American" ]
            ]
        ]
```