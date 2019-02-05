// Copyright DApps Platform Inc. All rights reserved.

import BigInt
import Foundation

struct Balance: BalanceProtocol {

    let value: BigInt

    init(value: BigInt) {
        self.value = value
    }

    var isZero: Bool {
        return value.isZero
    }

    var amountShort: String {
        return MoacNumberFormatter.short.string(from: value)
    }

    var amountFull: String {
        return MoacNumberFormatter.full.string(from: value)
    }
}
