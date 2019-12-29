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


type alias Item msg =
    FocusList.Item msg


type Msg
    = FocusMsg FocusList.Msg
    | DropMsg Dropdown
    | SelectFirst FocusList.Msg


type alias Menu =
    { list : FocusList
    , drop : Dropdown
    }


link : String -> List (Attribute msg) -> List (Html msg) -> Item msg
link path attrs children =
    FocusList.Anchor ( path, attrs, children )


button : String -> List (Attribute msg) -> List (Html msg) -> Item msg
button value attrs children =
    FocusList.Button ( value, attrs, children )


init : String -> Menu
init name =
    { list = name
    , drop = Dropdown.closed
    }


view : Menu -> List (Attribute Msg) -> List (Item Msg) -> Html Msg
view { drop, list } attrs children =
    Dropdown.view DropMsg
        drop
        (FocusList.onKeyDown list FocusMsg :: FocusList.onSelect (\_ -> DropMsg Dropdown.closed) list :: attrs)
        (FocusList.view list children)


open : Menu -> Menu
open menu =
    { menu | drop = Dropdown.open }


close : Menu -> Menu
close menu =
    { menu | drop = Dropdown.closed }


onSelect : (String -> msg) -> Menu -> Attribute msg
onSelect toMsg { drop, list } =
    FocusList.onSelect toMsg list


trigger : (Msg -> msg) -> Menu -> List (Attribute msg)
trigger toMsg menu =
    id menu.list
        :: FocusList.trigger (SelectFirst >> toMsg)
        :: Dropdown.trigger (DropMsg >> toMsg) menu.drop


update : Msg -> Menu -> ( Menu, Cmd Msg )
update msg model =
    case msg of
        DropMsg drop ->
            ( { model | drop = drop }, Cmd.none )

        FocusMsg subMsg ->
            ( model, Cmd.map FocusMsg <| FocusList.update subMsg model.list )

        SelectFirst subMsg ->
            update (FocusMsg subMsg) (open model)
