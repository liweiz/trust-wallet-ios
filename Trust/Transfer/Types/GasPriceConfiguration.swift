// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

public struct GasPriceConfiguration {
    static let `default`: BigInt = MoacNumberFormatter.full.number(from: "24", units: UnitConfiguration.gasPriceUnit)!
    static let min: BigInt = MoacNumberFormatter.full.number(from: "1", units: UnitConfiguration.gasPriceUnit)!
    static let max: BigInt = MoacNumberFormatter.full.number(from: "100", units: UnitConfiguration.gasPriceUnit)!
}
