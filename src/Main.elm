module Main where

import Color
import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Input as Input
import Text
import Mouse
import Window

import Dict exposing (Dict)
import Task exposing (Task, andThen, succeed)
import Signal exposing (message, Mailbox, mailbox)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE

import ElmFire exposing (Error, Reference)
import ElmFire.Dict
import ElmFire.Op

firebaseUrl = "https://elmfire.firebaseio-demo.com/stamps"
firebaseLocation = ElmFire.fromUrl firebaseUrl

-- The model is a collection of the positions of all currently shown stamps
-- It is mirrored from a Firebase collection
type alias Model = Dict String Position
type alias Position = (Int, Int)

-- Render the varying model state
main : Signal Element
main = Signal.map2 view Window.dimensions states

-- Setup the mirroring of the Firebase collection as the local model
(initSubscriptionTask, states) =
  ElmFire.Dict.mirror elmfireConfig

-- Configure the mirroring
elmfireConfig : ElmFire.Dict.Config Position
elmfireConfig =
  { location = firebaseLocation
  , orderOptions = ElmFire.noOrder
  , encoder = (\pos -> JE.list [JE.int <| fst pos, JE.int <| snd pos])
  , decoder = JD.tuple2 (,) JD.int JD.int
  }

-- Input target for the "Clear" button
clearMailbox : Mailbox Bool
clearMailbox = mailbox False

-- All the tasks that are performed by the app
port firebaseTasks : Signal (Task Error ())
port firebaseTasks =
  Signal.mergeMany
    [ -- perform initialization
      Signal.constant (initSubscriptionTask `andThen` \_ -> succeed ())
    , -- push mouse positions to the Firebase
      Signal.map
        ( \pos ->
            Task.spawn
              ( ElmFire.Op.operate elmfireConfig (ElmFire.Op.push pos)
                -- remove again after some time
                `andThen` \ref -> Task.sleep 1000
                `andThen` \_ -> ElmFire.remove (ElmFire.location ref)
              )
            `andThen` \_ -> succeed ()
        )
        Mouse.position
    , -- clear the Firebase on button click
      Signal.map
        ( \_ -> ElmFire.remove firebaseLocation `andThen` \_ -> succeed () )
        clearMailbox.signal
    ]

view : (Int,Int) -> Model -> Element
view (w,h) state =
  let
    drawPentagon (x,y) =
      ngon 5 20
      |> filled (Color.hsla (toFloat x) 0.9 0.6 0.7)
      |> move (toFloat x - toFloat w / 2, toFloat h / 2 - toFloat y)
      |> rotate (toFloat x)
  in
    layers
      [ collage w h (List.map (snd >> drawPentagon) (Dict.toList state))
      , flow down
         [ flow right
           [ leftAligned <| Text.fromString "StampFire - "
           , link "https://github.com/ThomasWeiser/stampfire"
              <| leftAligned <| Text.fromString "Browse source"
           ]
         , flow right
           [ leftAligned <| Text.fromString "Demo of "
           , link "http://package.elm-lang.org/packages/ThomasWeiser/elmfire-extra/latest"
              <| leftAligned <| Text.fromString "elmfire-extra"
           ]
         , flow right
           [ leftAligned <| Text.fromString "Using Firebase at "
           , link firebaseUrl <| leftAligned <| Text.fromString firebaseUrl
           ]
         , Input.button (message clearMailbox.address True) "Clear"
         ]
      ]
