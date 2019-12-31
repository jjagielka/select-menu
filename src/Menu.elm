module Menu exposing
    ( Item, Menu, Msg
    , init, update, view
    , link, button
    , open, trigger, onSelect
    )

{-| Probably the simplest implementation of the dropdown.


# Types

@docs Item, Menu, Msg


# TEA

@docs init, update, view


# Items

@docs link, button


# Events

@docs open, trigger, onSelect

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, href, id)
import Menu.Dropdown as Dropdown exposing (Dropdown)
import Menu.FocusList as FocusList exposing (FocusList)


{-| Menu item type.
-}
type alias Item msg =
    FocusList.Item msg


{-| Internal select/menu messages.
-}
type Msg
    = FocusMsg FocusList.Msg
    | DropMsg Dropdown
    | SelectFirst FocusList.Msg


{-| Menu type.
-}
type Menu
    = Menu FocusList Dropdown


{-| Html link menu item. Click/Enter triggers url redirection.
-}
link : String -> List (Attribute msg) -> List (Html msg) -> Item msg
link path attrs children =
    FocusList.Anchor ( path, attrs, children )


{-| Button like menu. Use it when you need select mode - no url redirection but
value collection. This is used with onSelect attributes.
-}
button : String -> List (Attribute msg) -> List (Html msg) -> Item msg
button value attrs children =
    FocusList.Button ( value, attrs, children )


{-| Initialize a menu object. As the browser focus is used, menu requires
unique identifier.
-}
init : String -> Menu
init name =
    Menu name Dropdown.closed


{-| Renders the menu. Attributes are used to style the dropdown container.
Second parameter is an arbitrary list of menut Item's.
-}
view : Menu -> List (Attribute Msg) -> List (Item Msg) -> Html Msg
view (Menu list drop) attrs children =
    Dropdown.view DropMsg
        drop
        (FocusList.onKeyDown list FocusMsg :: FocusList.onSelect (\_ -> DropMsg Dropdown.closed) list :: attrs)
        (FocusList.view list children)


{-| Changes the menu state to Open
-}
open : Menu -> Menu
open (Menu list _) =
    Menu list Dropdown.open


{-| Changes the menu state to Closed
-}
close : Menu -> Menu
close (Menu list _) =
    Menu list Dropdown.closed


{-| Menu selection catching. Add this as a Html.Attribute to the container carring the menu.
-}
onSelect : (String -> msg) -> Menu -> Attribute msg
onSelect toMsg (Menu list _) =
    FocusList.onSelect toMsg list


{-| Menu control. Add that set of attributes to the element controling the menu: button, input, ...
-}
trigger : (Msg -> msg) -> Menu -> List (Attribute msg)
trigger toMsg (Menu list drop) =
    id list
        :: FocusList.trigger (SelectFirst >> toMsg)
        :: Dropdown.trigger (DropMsg >> toMsg) drop


{-| Standard elm update.
-}
update : Msg -> Menu -> ( Menu, Cmd Msg )
update msg ((Menu list _) as menu) =
    case msg of
        DropMsg drop ->
            ( Menu list drop, Cmd.none )

        FocusMsg subMsg ->
            ( menu, Cmd.map FocusMsg <| FocusList.update subMsg list )

        SelectFirst subMsg ->
            update (FocusMsg subMsg) (open menu)
