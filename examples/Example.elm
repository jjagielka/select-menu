module Example exposing (main)

import Browser exposing (element)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, href, style)
import Menu exposing (Menu)


type alias Model =
    { menu : Menu
    , select : Menu
    , selected : String
    }


type Msg
    = MenuMsg Menu.Msg
    | SelectMsg Menu.Msg
    | Selected String


init : () -> ( Model, Cmd Msg )
init flags =
    ( { menu = Menu.init "unique-menu-name"
      , select = Menu.init "unique-select-name"
      , selected = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MenuMsg subMsg ->
            let
                ( menu, cmd ) =
                    Menu.update subMsg model.menu
            in
            ( { model | menu = menu }, Cmd.map MenuMsg cmd )

        SelectMsg subMsg ->
            let
                ( select, cmd ) =
                    Menu.update subMsg model.select
            in
            ( { model | select = select }, Cmd.map SelectMsg cmd )

        Selected value ->
            ( { model | selected = value }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Html.node "style" [] [ text css ]
        , div [ style "float" "left", style "width" "30%" ] [ simpleMenu model ]
        , div [ style "float" "left", style "width" "30%", style "padding" "0.75em" ]
            [ simpleSelect model
            , Html.b [] [ text " Selected value: " ]
            , text model.selected
            ]
        ]



-- Simple dropdown menu


simpleMenu : Model -> Html Msg
simpleMenu { menu } =
    Html.ul []
        [ Html.li [] [ Html.a [] [ text "Home" ] ]
        , Html.li []
            [ Menu.view menu
                [ class "menu" ]
                [ Menu.link "#popular" [ class "item" ] [ text "Popular" ]
                , Menu.link "#viewed" [ class "item" ] [ text "Most viewed" ]
                , Menu.link "#rated" [ class "item" ] [ text "Best rated" ]
                ]
                |> Html.map MenuMsg
            , Html.a (href "#" :: Menu.trigger MenuMsg menu) [ text " Videos " ]
            ]
        , Html.li [] [ Html.a [ href "#" ] [ text " Audios " ] ]
        ]



-- Select behaviour


simpleSelect : Model -> Html Msg
simpleSelect { select } =
    Html.span [ Menu.onSelect Selected select ]
        [ Menu.view select
            [ class "select" ]
            [ Menu.button "" [ class "item" ] [ Html.i [] [ text "No preferences" ] ]
            , Menu.button "CO" [ class "item" ] [ text "Continental" ]
            , Menu.button "EN" [ class "item" ] [ text "English" ]
            , Menu.button "AM" [ class "item" ] [ text "American" ]
            ]
            |> Html.map SelectMsg
        , button (Menu.trigger SelectMsg select) [ text "What's your breakfast type?" ]
        ]


main =
    element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


css =
    """
    .menu {
        margin: 19px 0px;
        box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
        width: 20.5em;
    }

    .select {
        margin: 10px 0px;
        border: 1px solid lightgray;
        width: 14.5em;
    }

    .item { 
        background-color: white;
        padding: 5px 10px;
        border: none;
        text-align: left;
        color: #333;
        display: inline-block;
        text-decoration: none;
    }
    .item:hover {
        background-color: lightgray;
    }
    .item:focus {
        background-color: #333;
        color: white;
        outline: none;
    }

    /* black navigation bar */
    ul {
        list-style-type: none;
        margin: 0;
        padding: 0;
        background-color: #333;
    }
    li {
        display: inline;
    }
    li  a {
        display: inline-block;
        color: white;
        text-align: center;
        padding: 14px 16px;
        text-decoration: none;
    }
    li a:hover {
        background-color: #111;
    }
    """
