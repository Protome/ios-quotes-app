#!/bin/sh


# Install CocoaPods using Homebrew.
#brew install cocoapods


# Install dependencies you manage with CocoaPods.
#pod install

printf "\"goodreads_key\"=\"%s\"; \n\"goodreads_secret\"=\"%s\";" "$GOODREADS_KEY" "$GOODREADS_SECRET" >> ../GoodQuotes/Secrets.Strings
