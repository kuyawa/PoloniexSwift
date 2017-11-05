//
//  Poloniex.swift
//  Poloniex
//
//  Created by Laptop on 11/4/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Foundation

// UTILS

extension Date {
    var epoch: Int { return Int(self.timeIntervalSince1970) }
    static var epoch: Int { return Int(Date().timeIntervalSince1970) }
    static var sinceMidnight: Int {
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        let day = cal.startOfDay(for: now)
        return Int(day.timeIntervalSince1970)
    }
}

extension String {
    // Uses CommonCrypto library in BridgingHeader.h
    func sha512(key: String) -> String {
        //let CC_SHA512_DIGEST_LENGTH = 64
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA512), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hexBytes = result.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension Bool {
    var int: Int { return self ? 1 : 0 }
}

/*
 Refer to https://poloniex.com/support/api/
 
 USE:
   Poloniex.Public.returnTicker { response in ... }
   Poloniex.Public.returnOrderBook(currencyPair: "BTC_LTC", depth: 20) { response in ... }
   Poloniex.Trading.returnBalances { response in ... }
   Poloniex.Trading.buy(currencyPair: "BTC_LTC", rate: 100.00, amount: 1.0) { response in ... }
 */

class Poloniex {
    
    struct Response {
        var error   = false
        var message = ""
        var content = ""
        var json    = [String:Any]()
        var list    = [Any]()
    }
    
    typealias Callback = (_ response: Response) -> Void
    
    class RequestAPI {
        func call(_ request: URLRequest, _ callback: @escaping Callback) {
            print("API CALL: ", request.url!)
            URLSession.shared.dataTask(with: request) { data, response, error in
                let result = self.handleResponse(data, response, error)
                callback(result)
            }.resume()
        }
        
        func handleResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Response {
            var result = Response()
            guard error == nil else {
                print("API ERROR: ", error!.localizedDescription)
                result.error = true
                result.message = error!.localizedDescription
                return result
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print("API RESPONSE")
                result.content = text
                // Accept both objects or arrays, arrays will be assigned to result.list
                let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                if let dixy = json as? [String:Any] {
                    result.json = dixy
                    print(dixy)
                } else if let list = json as? [Any] {
                    result.list = list
                    print(list)
                }
            }
            
            return result
        }
    }


    // Public interface

    static var API     = RequestAPI()
    static var Public  = PublicAPI()
    static var Trading = TradingAPI()

    
    class PublicAPI {
        private let uri = "https://poloniex.com/public"   // GET all requests
        
        private func buildRequest(_ parameters: [String:Any?]) -> URLRequest {
            let url = URL(string: uri)!
            var query = [URLQueryItem]()
            
            for (key, val) in parameters {
                if let value = val {
                    query.append(URLQueryItem(name: key, value: "\(value)"))
                }
            }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.queryItems = query
            var request = URLRequest(url: components.url!)
            request.setValue("Poloniex Swift Bot 1.0", forHTTPHeaderField: "User-Agent")
            
            return request
        }
        
        // PUBLIC CALLS
        
        // Returns the ticker for all markets
        // https://poloniex.com/public?command=returnTicker
        
        func returnTicker(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnTicker"])
            API.call(request, callback)
        }

        // Returns the 24-hour volume for all markets, plus totals for primary currencies
        // https://poloniex.com/public?command=return24hVolume
        
        func return24hVolume(callback: @escaping Callback) {
            let request = buildRequest(["command":"return24hVolume"])
            API.call(request, callback)
        }
        
        // Returns the order book for a given market, as well as a sequence number for use with the Push API
        // Also an indicator specifying whether the market is frozen
        // You may set currencyPair to "all" to get the order books of all markets
        // https://poloniex.com/public?command=returnOrderBook&currencyPair=BTC_NXT&depth=10
        
        func returnOrderBook(currencyPair: String = "BTC_LTC", depth: Int = 10, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnOrderBook", "currencyPair":currencyPair, "depth":depth])
            API.call(request, callback)
        }
        
        // Returns the past 200 trades for a given market, or up to 50,000 trades between a range specified in UNIX timestamps by the "start" and "end" GET parameters
        // https://poloniex.com/public?command=returnTradeHistory&currencyPair=BTC_NXT&start=1410158341&end=1410499372
        
        func returnTradeHistory(currencyPair: String = "BTC_LTC", start: Int? = nil, end: Int? = nil, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnTradeHistory", "currencyPair":currencyPair, "start":start, "end":end])
            API.call(request, callback)
        }
        
        // Returns candlestick chart data. Required GET parameters are "currencyPair", "period", "start", and "end"
        // Candlestick period in seconds; valid values are 300, 900, 1800, 7200, 14400, and 86400
        // Start and end are given in UNIX timestamp format and used to specify the date range for the data returned
        // https://poloniex.com/public?command=returnChartData&currencyPair=BTC_XMR&start=1405699200&end=9999999999&period=14400
        
        func returnChartData(currencyPair: String = "BTC_LTC", start: Int = Date.sinceMidnight, end: Int = 9999999999000, period: Int = 1800, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnChartData", "currencyPair":currencyPair, "start":start, "end":end, "period":period])
            API.call(request, callback)
        }
        
        // Returns information about currencies
        // https://poloniex.com/public?command=returnCurrencies
        
        func returnCurrencies(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnCurrencies"])
            API.call(request, callback)
        }
        
        // Returns the list of loan offers and demands for a given currency, specified by the "currency" GET parameter
        // https://poloniex.com/public?command=returnLoanOrders&currency=BTC
        
        func returnLoanOrders(currency: String = "BTC", callback: @escaping Callback) {
            let request = buildRequest(["command":"returnLoanOrders", "currency":currency])
            API.call(request, callback)
        }
    }

    
    class TradingAPI {
        // TODO: MOVE SECRET STUFF TO SECRET FILE!!!
        private let uri = "https://poloniex.com/tradingApi"   // POST all requests
        private let bot = "Poloniex Swift Bot 1.0"
        private let key = "YOUR-SECRET-KEY"
        private let sec = "YOUR-SECRET-SECRET"
        
        private func buildRequest(_ parameters: [String:Any?]) -> URLRequest {
            let nonce = Date.epoch
            var query = [URLQueryItem]()
            
            for (par, val) in parameters {
                if let value = val {
                    query.append(URLQueryItem(name: par, value: "\(value)"))
                }
            }
            
            query.append(URLQueryItem(name: "nonce", value: "\(nonce)"))
            
            var components = URLComponents()
            components.queryItems = query
            
            let body = components.query!
            let data = body.data(using: .utf8)!
            let sign = body.sha512(key: sec)

            //print("Body", body)
            //print("Sign", sign)
            
            let url = URL(string: uri)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody   = data
            request.setValue(bot , forHTTPHeaderField: "User-Agent")
            request.setValue(key , forHTTPHeaderField: "Key")
            request.setValue(sign, forHTTPHeaderField: "Sign")
            
            return request
        }
        
        
        // TRADING CALLS
        
        func returnBalances(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnBalances"])
            API.call(request, callback)
        }
        
        func returnCompleteBalances(account: String = "all", callback: @escaping Callback) {
            let request = buildRequest(["command":"returnCompleteBalances", "account":account])
            API.call(request, callback)
        }
        
        func returnDepositAddress(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnDepositAddresses"])
            API.call(request, callback)
        }
        
        func generateNewAddress(currency: String = "BTC", callback: @escaping Callback) {
            let request = buildRequest(["command":"generateNewAddress", "currency":currency])
            API.call(request, callback)
        }
        
        func returnDepositsWithdrawals(start: Int, end: Int, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnDepositsWithdrawals", "start":start, "end":end])
            API.call(request, callback)
        }
        
        func returnOpenOrders(currencyPair: String = "all", callback: @escaping Callback) {
            let request = buildRequest(["command":"returnOpenOrders", "currencyPair":currencyPair])
            API.call(request, callback)
        }
        
        func returnTradeHistory(currencyPair: String = "all", start: Int?, end: Int?, limit: Int? = 100, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnTradeHistory", "currencyPair":currencyPair, "start":start, "end":end, "limit":limit])
            API.call(request, callback)
        }
        
        func returnOrderTrades(orderNumber: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnOrderTrades", "orderNumber":orderNumber])
            API.call(request, callback)
        }
        
        func buy(currencyPair: String, rate: Double, amount: Double, fillOrKill: Int?, immediateOrCancel: Int?, postOnly: Int?, callback: @escaping Callback) {
            let request = buildRequest(["command":"buy", "currencyPair":currencyPair, "rate":rate, "amount":amount, "fillOrKill":fillOrKill, "immediateOrCancel":immediateOrCancel, "postOnly":postOnly])
            API.call(request, callback)
        }
        
        func sell(currencyPair: String, rate: Double, amount: Double, fillOrKill: Int?, immediateOrCancel: Int?, postOnly: Int?, callback: @escaping Callback) {
            let request = buildRequest(["command":"sell", "currencyPair":currencyPair, "rate":rate, "amount":amount, "fillOrKill":fillOrKill, "immediateOrCancel":immediateOrCancel, "postOnly":postOnly])
            API.call(request, callback)
        }
        
        func cancelOrder(orderNumber: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"cancelOrder", "orderNumber":orderNumber])
            API.call(request, callback)
        }
        
        func moveOrder(orderNumber: String, rate: Double, amount: Double?, immediateOrCancel: Int?, postOnly: Int?, callback: @escaping Callback) {
            let request = buildRequest(["command":"moveOrder", "orderNumber":orderNumber, "amount":amount, "immediateOrCancel":immediateOrCancel, "postOnly":postOnly])
            API.call(request, callback)
        }
        
        func withdraw(currency: String, amount: Double, address: String, paymentId: String?, callback: @escaping Callback) {
            let request = buildRequest(["command":"withdraw", "currency":currency, "amount":amount, "address":address, "paymentId":paymentId])
            API.call(request, callback)
        }
        
        func returnFeeInfo(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnFeeInfo"])
            API.call(request, callback)
        }
        
        func returnAvailableAccountBalances(account: String?, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnAvailableAccountBalances", "account":account])
            API.call(request, callback)
        }
        
        func returnTradableBalances(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnTradableBalances"])
            API.call(request, callback)
        }
        
        func transferBalance(currency: String, amount: Double, fromAccount: String, toAccount: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"transferBalance", "currency":currency, "amount":amount, "fromAccount":fromAccount, "toAccount":toAccount])
            API.call(request, callback)
        }
        
        func returnMarginAccountSummary(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnMarginAccountSummary"])
            API.call(request, callback)
        }
        
        func marginBuy(currencyPair: String, rate: Double, amount: Double, lendingRate: Double?, callback: @escaping Callback) {
            let request = buildRequest(["command":"marginBuy", "currencyPair":currencyPair, "rate":rate, "amount":amount, "lendingRate":lendingRate])
            API.call(request, callback)
        }
        
        func marginSell(currencyPair: String, rate: Double, amount: Double, lendingRate: Double?, callback: @escaping Callback) {
            let request = buildRequest(["command":"marginSell", "currencyPair":currencyPair, "rate":rate, "amount":amount, "lendingRate":lendingRate])
            API.call(request, callback)
        }
        
        func getMarginPosition(currencyPair: String = "all", callback: @escaping Callback) {
            let request = buildRequest(["command":"getMarginPosition", "currencyPair":currencyPair])
            API.call(request, callback)
        }
        
        func closeMarginPosition(currencyPair: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"closeMarginPosition", "currencyPair":currencyPair])
            API.call(request, callback)
        }
        
        func createLoanOffer(currency: String, amount: Double, duration: Int, autoRenew: Int, lendingRate: Double, callback: @escaping Callback) {
            let request = buildRequest(["command":"createLoanOffer", "currency":currency, "amount":amount, "duration":duration, "autoRenew":autoRenew, "lendingRate":lendingRate])
            API.call(request, callback)
        }
        
        func cancelLoanOffer(orderNumber: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"cancelLoanOffer", "orderNumber":orderNumber])
            API.call(request, callback)
        }
        
        func returnOpenLoanOffers(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnOpenLoanOffers"])
            API.call(request, callback)
        }
        
        func returnActiveLoans(callback: @escaping Callback) {
            let request = buildRequest(["command":"returnActiveLoans"])
            API.call(request, callback)
        }
        
        func returnLendingHistory(start: Int, end: Int, limit: Int?, callback: @escaping Callback) {
            let request = buildRequest(["command":"returnLendingHistory", "start":start, "end":end, "limit":limit])
            API.call(request, callback)
        }
        
        func toggleAutoRenew(orderNumber: String, callback: @escaping Callback) {
            let request = buildRequest(["command":"toggleAutoRenew", "orderNumber":orderNumber])
            API.call(request, callback)
        }
    }
}

// END
