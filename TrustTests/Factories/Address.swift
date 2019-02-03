// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension MoacAddress {
    static func make(
        address: String = "0x0000000000000000000000000000000000000001"
    ) -> MoacAddress {
        return MoacAddress(
            string: address
        )!
    }
}
