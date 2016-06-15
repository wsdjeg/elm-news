module Tag exposing (TagInfo, view)

import Html exposing (Html, div, a, text)
import Html.Attributes exposing (class, href)
import Dict
import Reddit
import HackerNews


type alias TagInfo =
    { name : String
    , tagColor : String
    , link : String
    }


view : String -> Html msg
view name =
    let
        tag =
            lookupTagInfo name
    in
        div [ class <| "tag " ++ tag.tagColor ]
            [ a
                [ href tag.link
                , class "tag__link"
                ]
                [ text tag.name ]
            ]


lookupTagInfo : String -> TagInfo
lookupTagInfo name =
    let
        default =
            TagInfo "unknown" "grey" ""

        lookup =
            Dict.empty
                |> Dict.insert "elm-discuss" elmDiscussTag
                |> Dict.insert "elm-dev" elmDevTag
                |> Dict.insert Reddit.tag redditTag
                |> Dict.insert HackerNews.tag hackerNewsTag
    in
        Maybe.withDefault default (Dict.get name lookup)


elmDiscussTag : TagInfo
elmDiscussTag =
    { name = "elm-discuss"
    , tagColor = "elm_light_blue"
    , link = "https://groups.google.com/forum/#!forum/elm-discuss"
    }


elmDevTag : TagInfo
elmDevTag =
    { name = "elm-dev"
    , tagColor = "elm_dark_blue"
    , link = "https://groups.google.com/forum/#!forum/elm-dev"
    }


redditTag : TagInfo
redditTag =
    { name = Reddit.tag
    , tagColor = "elm_yellow"
    , link = "https://www.reddit.com/r/elm/new"
    }


hackerNewsTag : TagInfo
hackerNewsTag =
    { name = HackerNews.tag
    , tagColor = "elm_green"
    , link = "https://news.ycombinator.com/"
    }