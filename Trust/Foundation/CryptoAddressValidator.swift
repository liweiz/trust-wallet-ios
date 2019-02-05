// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum AddressValidatorType {
    case moac

    var addressLength: Int {
        switch self {
        case .moac: return 42
        }
    }
}

struct CryptoAddressValidator {
    static func isValidAddress(_ value: String?, type: AddressValidatorType = .moac) -> Bool {
        return value?.range(of: "^0x[a-fA-F0-9]{40}$", options: .regularExpression) != nil
    }
}
