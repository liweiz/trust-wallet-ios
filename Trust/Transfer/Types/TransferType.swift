// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct Transfer {
    let server: RPCServer
    let type: TransferType
}

enum TransferType {
//    case ether(TokenObject, destination: MoacAddress?)
    case moac(TokenObject, destination: MoacAddress?)
    case token(TokenObject)
    case dapp(TokenObject, DAppRequester)
}

extension TransferType {
    func symbol(server: RPCServer) -> String {
        switch self {
        case .moac, .dapp:
            return server.symbol
        case .token(let token):
            return token.symbol
        }
    }

    //used for pricing
    var contract: String {
        switch self {
        case .moac(let token, _):
            return token.contract
        case .dapp(let token, _):
            return token.contract
        case .token(let token):
            return token.contract
        }
    }

    var token: TokenObject {
        switch self {
        case .moac(let token, _):
            return token
        case .dapp(let token, _):
            return token
        case .token(let token):
            return token
        }
    }

    var address: MoacAddress {
        switch self {
        case .moac(let token, _):
            return token.address
        case .dapp(let token, _):
            return token.address
        case .token(let token):
            return token.address
        }
    }
}
