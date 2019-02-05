// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import PromiseKit
import BigInt
import APIKit
import JSONRPCKit

final class TokenNetworkProvider: BalanceNetworkProvider {

    let server: RPCServer
    let address: MoacAddress
    let contract: MoacAddress
    let addressUpdate: MoacAddress

    init(
        server: RPCServer,
        address: MoacAddress,
        contract: MoacAddress,
        addressUpdate: MoacAddress
    ) {
        self.server = server
        self.address = address
        self.contract = contract
        self.addressUpdate = addressUpdate
    }

    func balance() -> Promise<BigInt> {
        return Promise { seal in
            let encoded = ERC20Encoder.encodeBalanceOf(address: address)
            let request = MoacServiceRequest(
                for: server,
                batch: BatchFactory().create(CallRequest(to: contract.description, data: encoded.hexEncoded))
            )
            Session.send(request) { result in
                switch result {
                case .success(let balance):
                    guard let value = BigInt(balance.drop0x, radix: 16) else {
                        return seal.reject(CookiesStoreError.empty)
                    }
                    seal.fulfill(value)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
