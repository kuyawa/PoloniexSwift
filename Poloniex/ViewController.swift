//
//  ViewController.swift
//  Poloniex
//
//  Created by Laptop on 11/4/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var output: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output.font = NSFont(name: "Monaco", size: 14.0)
        test01()  // RUN ONE TEST AT A TIME
    }

    func log(_ response: Poloniex.Response) {
        if response.error {
            print("Error:", response.message)
            DispatchQueue.main.async {
                self.output.string = response.message
            }
        } else {
            //print("Result:", response.content)
            DispatchQueue.main.async {
                self.output.string = response.content
            }
        }
    }
    
    // PUBLIC
    func test01() { Poloniex.Public.returnTicker       { response in self.log(response) } }
    func test02() { Poloniex.Public.return24hVolume    { response in self.log(response) } }
    func test03() { Poloniex.Public.returnOrderBook    { response in self.log(response) } }
    func test04() { Poloniex.Public.returnTradeHistory { response in self.log(response) } }
    func test05() { Poloniex.Public.returnChartData    { response in self.log(response) } }
    func test06() { Poloniex.Public.returnCurrencies   { response in self.log(response) } }
    func test07() { Poloniex.Public.returnLoanOrders   { response in self.log(response) } }
    
    // TRADING
    func test08() { Poloniex.Trading.returnBalances         { response in self.log(response) } }
    func test09() { Poloniex.Trading.returnCompleteBalances { response in self.log(response) } }
    func test10() { Poloniex.Trading.returnDepositAddress   { response in self.log(response) } }
    /* NOTE: Not all methods can be tested like buy, sell, etc
             some need extra parameters and may affect your account
    func test11() { Poloniex.Trading.generateNewAddress         { response in self.log(response) } }
    func test12() { Poloniex.Trading.returnDepositsWithdrawals  { response in self.log(response) } }
    func test13() { Poloniex.Trading.returnOpenOrders           { response in self.log(response) } }
    func test14() { Poloniex.Trading.returnTradeHistory         { response in self.log(response) } }
    func test15() { Poloniex.Trading.returnOrderTrades          { response in self.log(response) } }
    func test16() { Poloniex.Trading.buy                        { response in self.log(response) } }
    func test17() { Poloniex.Trading.sell                       { response in self.log(response) } }
    func test18() { Poloniex.Trading.cancelOrder                { response in self.log(response) } }
    func test19() { Poloniex.Trading.moveOrder                  { response in self.log(response) } }
    func test20() { Poloniex.Trading.withdraw                   { response in self.log(response) } }
    func test21() { Poloniex.Trading.returnFeeInfo              { response in self.log(response) } }
    func test22() { Poloniex.Trading.returnAvailableAccountBalances { response in self.log(response) } }
    func test23() { Poloniex.Trading.returnTradableBalances     { response in self.log(response) } }
    func test24() { Poloniex.Trading.transferBalance            { response in self.log(response) } }
    func test25() { Poloniex.Trading.returnMarginAccountSummary { response in self.log(response) } }
    func test26() { Poloniex.Trading.marginBuy                  { response in self.log(response) } }
    func test27() { Poloniex.Trading.marginSell                 { response in self.log(response) } }
    func test28() { Poloniex.Trading.getMarginPosition          { response in self.log(response) } }
    func test29() { Poloniex.Trading.closeMarginPosition        { response in self.log(response) } }
    func test30() { Poloniex.Trading.createLoanOffer            { response in self.log(response) } }
    func test31() { Poloniex.Trading.cancelLoanOffer            { response in self.log(response) } }
    func test32() { Poloniex.Trading.returnOpenLoanOffers       { response in self.log(response) } }
    func test33() { Poloniex.Trading.returnActiveLoans          { response in self.log(response) } }
    func test34() { Poloniex.Trading.returnLendingHistory       { response in self.log(response) } }
    func test35() { Poloniex.Trading.toggleAutoRenew            { response in self.log(response) } }
    */
}

// END
