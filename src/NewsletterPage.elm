module NewsletterPage exposing (Model, Msg, init, view, update, onPageLoad)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Newsletter.Newsletter as Newsletter exposing (Newsletter, Article)
import Newsletter.NewsletterFile exposing (NewsletterFile)
import News.View as News exposing (DisplayStory)
import Http
import Task
import Analytics exposing (Event)
import Components.Icons
import Navigation
import Links


type alias Model =
    { newsletter : Content
    }


type Content
    = Fetching
    | Fetched Newsletter
    | Error Http.Error


init : Model
init =
    { newsletter = Fetching
    }


onPageLoad : String -> Cmd Msg
onPageLoad name =
    Task.perform
        FailedToFetchNewsletter
        FetchedNewsletter
        (Newsletter.fetch name)


type Msg
    = FailedToFetchNewsletter Http.Error
    | FetchedNewsletter Newsletter
    | ClickEvent Event
    | GoToArticle String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FailedToFetchNewsletter error ->
            let
                _ =
                    Debug.log "error" error
            in
                { model | newsletter = Error error } ! []

        FetchedNewsletter newsletter ->
            { model | newsletter = Fetched newsletter } ! []

        ClickEvent event ->
            model ! [ Analytics.registerEvent event ]

        GoToArticle name ->
            model
                ! [ Links.newsletter name
                        |> Navigation.newUrl
                  ]

        NoOp ->
            model ! []


view : Int -> List NewsletterFile -> String -> Model -> Html Msg
view screenWidth files filename model =
    case model.newsletter of
        Fetching ->
            text "fetching"

        Error error ->
            text "error"

        Fetched newsletter ->
            displayNewsletter screenWidth files filename newsletter


displayNewsletter : Int -> List NewsletterFile -> String -> Newsletter -> Html Msg
displayNewsletter screenWidth files filename newsletter =
    if screenWidth >= 600 then
        div [ class "newsletter__body" ]
            [ navIcon previousArticle Components.Icons.left files filename "newsletter__nav"
            , articles screenWidth files filename newsletter
            , navIcon nextArticle Components.Icons.right files filename "newsletter__nav"
            ]
    else
        div [ class "newsletter__body_min" ]
            [ articles screenWidth files filename newsletter
            , div [ class "newsletter__controls" ]
                [ navIcon previousArticle Components.Icons.left files filename "newsletter__nav_min"
                , navIcon nextArticle Components.Icons.right files filename "newsletter__nav_min"
                ]
            ]


articles : Int -> List NewsletterFile -> String -> Newsletter -> Html Msg
articles screenWidth files filename newsletter =
    div [ class "newsletter__articles" ]
        [ h1 [ class "newsletter__header" ] [ text (title newsletter) ]
        , News.view
            { now = Nothing
            , screenWidth = screenWidth
            , onLinkClick = ClickEvent
            }
            (List.map toDisplayStory newsletter.articles)
        ]


title : Newsletter -> String
title newsletter =
    "Top News for "
        ++ newsletter.startDate
        ++ " - "
        ++ newsletter.endDate
        ++ ", "
        ++ newsletter.year


toDisplayStory : Article -> DisplayStory
toDisplayStory article =
    { from = article.from
    , title = article.title
    , date = Nothing
    , url = article.url
    , tag = article.tag
    }


navIcon :
    (String -> List NewsletterFile -> Maybe NewsletterFile)
    -> (String -> Int -> Msg -> Html Msg)
    -> List NewsletterFile
    -> String
    -> String
    -> Html Msg
navIcon findArticle icon files filename baseClass =
    case findArticle filename files of
        Just file ->
            icon baseClass 48 (GoToArticle file.name)

        Nothing ->
            icon "newsletter__nav_disabled" 48 NoOp


previousArticle : String -> List NewsletterFile -> Maybe NewsletterFile
previousArticle name files =
    case files of
        [] ->
            Nothing

        x :: [] ->
            Nothing

        x :: y :: z ->
            if y.name == name then
                Just x
            else
                previousArticle name (y :: z)


nextArticle : String -> List NewsletterFile -> Maybe NewsletterFile
nextArticle name files =
    case files of
        [] ->
            Nothing

        x :: [] ->
            Nothing

        x :: y :: z ->
            if x.name == name then
                Just y
            else
                nextArticle name (y :: z)
