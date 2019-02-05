// Copyright DApps Platform Inc. All rights reserved.

import Foundation

extension MoacNumberFormatter {
    static let balance: MoacNumberFormatter = {
        let formatter = MoacNumberFormatter()
        formatter.maximumFractionDigits = 7
        return formatter
    }()
}
