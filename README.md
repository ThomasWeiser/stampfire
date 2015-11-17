# Demonstration of Firebase interfacing with Elm packages [elmfire](http://package.elm-lang.org/packages/ThomasWeiser/elmfire/latest)([-extra](http://package.elm-lang.org/packages/ThomasWeiser/elmfire-extra/latest/))

## [Run demo](http://thomasweiser.github.io/stampfire/)

## Background

[ElmFire](http://package.elm-lang.org/packages/ThomasWeiser/elmfire/latest/) ([source code](https://github.com/ThomasWeiser/elmfire)) is an [Elm](http://elm-lang.org/) library that provides the raw [Firebase JavaScript](https://www.firebase.com/docs/web/) functionality to Elm apps. On top of that [elmfire-extra](http://package.elm-lang.org/packages/ThomasWeiser/elmfire-extra/latest/) ([source code](https://github.com/ThomasWeiser/elmfire-extra)) makes it easy to treat Firebase data like a local Elm [dictionary](http://package.elm-lang.org/packages/elm-lang/core/latest/Dict) with corresponding operations on it.

## Cooperative drawing demo

This demo is an extension of the Elm example [Stamps](http://elm-lang.org/examples/stamps) by adding Firebase syncing of the current state. This way multiple users can work with a shared data model.

Other deviations from the original demo are that the stamps a drawn on mouse movement without the need to click and that the stamps a removed automatically after some time.
