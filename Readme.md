# POLONIEX SWIFT

PoloniexSwift is a wrapper for all API calls offered by Poloniex to access your crypto account. It has all public and trading methods some of which require your secret key and a hash of the information sent using your secret code. Be careful not to store your secret info in your code.

Link to Poloniex API: [https://poloniex.com/support/api/](https://poloniex.com/support/api/)

## How to use it? 

As simple as this:

    Poloniex.Public.returnTicker { response in print(response.content) }

The response object has some useful properties like 'error' and 'message' in case something went wrong, also json dictionaries and json arrays as well as the string content of the response

The easiest way to check for errors is like this:

    if response.error { print(response.message) }

Else, use the json dictionary provided:

    print(response.json["BTC_LTC"]["last"])

Version 2 will use Structs for all responses instead of json

## Tools

Developed with Xcode 8.3 and Swift 3.1

## Dependencies

Poloniex.swift uses CryptoCommon via BridgingHeader.h

