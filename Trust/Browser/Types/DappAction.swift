// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt
import TrustCore
import WebKit

enum DappAction {
    case signMessage(String)
    case signPersonalMessage(String)
    case signTypedMessage([McTypedData])
    case signTransaction(UnconfirmedTransaction)
    case sendTransaction(UnconfirmedTransaction)
    case unknown
}

extension DappAction {
    static func fromCommand(_ command: DappCommand, transfer: Transfer) -> DappAction {
        switch command.name {
        case .signTransaction:
            return .signTransaction(DappAction.makeUnconfirmedTransaction(command.object, transfer: transfer))
        case .sendTransaction:
            return .sendTransaction(DappAction.makeUnconfirmedTransaction(command.object, transfer: transfer))
        case .signMessage:
            let data = command.object["data"]?.value ?? ""
            return .signMessage(data)
        case .signPersonalMessage:
            let data = command.object["data"]?.value ?? ""
            return .signPersonalMessage(data)
        case .signTypedMessage:
            let array = command.object["data"]?.array ?? []
            return .signTypedMessage(array)
        case .unknown:
            return .unknown
        }
    }

    private static func makeUnconfirmedTransaction(_ object: [String: DappCommandObjectValue], transfer: Transfer) -> UnconfirmedTransaction {
        let to = MoacAddress(string: object["to"]?.value ?? "")
        let value = BigInt((object["value"]?.value ?? "0").drop0x, radix: 16) ?? BigInt()
        let nonce: BigInt? = {
            guard let value = object["nonce"]?.value else { return .none }
            return BigInt(value.drop0x, radix: 16)
        }()
        let gasLimit: BigInt? = {
            guard let value = object["gasLimit"]?.value ?? object["gas"]?.value else { return .none }
            return BigInt((value).drop0x, radix: 16)
        }()
        let gasPrice: BigInt? = {
            guard let value = object["gasPrice"]?.value else { return .none }
            return BigInt((value).drop0x, radix: 16)
        }()
        let shardingFlag: BigInt? = {
            guard let value = object["shardingFlag"]?.value else { return .none }
            return BigInt((value).drop0x, radix: 16)
        }()
        let systemContract: BigInt? = {
            guard let value = object["systemContract"]?.value else { return .none }
            return BigInt((value).drop0x, radix: 16)
        }()
        let via = MoacAddress(string: object["via"]?.value ?? "")
        let data = Data(hex: object["data"]?.value ?? "0x")

        return UnconfirmedTransaction(
            transfer: transfer,
            value: value,
            to: to,
            data: data,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: nonce,
            shardingFlag: shardingFlag,
            systemContract: systemContract,
            via: via
        )
    }

    static func fromMessage(_ message: WKScriptMessage) -> DappCommand? {
        let decoder = JSONDecoder()
        guard let body = message.body as? [String: AnyObject],
            let jsonString = body.jsonString,
            let command = try? decoder.decode(DappCommand.self, from: jsonString.data(using: .utf8)!) else {
                return .none
        }
        return command
    }
}
