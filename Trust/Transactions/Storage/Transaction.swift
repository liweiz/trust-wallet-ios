// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

final class Transaction: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var uniqueID: String = ""
    @objc dynamic var blockNumber: Int = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gas = ""
    @objc dynamic var gasPrice = ""
    @objc dynamic var gasUsed = ""
    @objc dynamic var nonce: Int = 0
    @objc dynamic var date = Date()
    @objc dynamic var internalState: Int = TransactionState.completed.rawValue
    
    @objc dynamic var shardingFlag = ""
    @objc dynamic var systemContract = ""
    @objc dynamic var via = ""

    @objc private dynamic var rawCoin = -1
    public var coin: Coin {
        get { return Coin(rawValue: rawCoin)! }
        set { rawCoin = newValue.rawValue }
    }

    var localizedOperations = List<LocalizedOperationObject>()

    convenience init(
        id: String,
        blockNumber: Int,
        from: String,
        to: String,
        value: String,
        gas: String,
        gasPrice: String,
        gasUsed: String,
        nonce: Int,
        shardingFlag: String,
        systemContract: String,
        via: String,
        date: Date,
        coin: Coin,
        localizedOperations: [LocalizedOperationObject],
        state: TransactionState
    ) {
        self.init()
        self.id = id
        self.uniqueID = from + "-" + String(nonce)
        self.blockNumber = blockNumber
        self.from = from
        self.to = to
        self.value = value
        self.gas = gas
        self.gasPrice = gasPrice
        self.gasUsed = gasUsed
        self.nonce = nonce
        self.shardingFlag = shardingFlag
        self.systemContract = systemContract
        self.via = via
        self.date = date
        self.coin = coin
        self.internalState = state.rawValue

        let list = List<LocalizedOperationObject>()
        localizedOperations.forEach { element in
            list.append(element)
        }

        self.localizedOperations = list
    }

    private enum TransactionCodingKeys: String, CodingKey {
        case id = "_id"
        case blockNumber
        case from
        case to
        case value
        case gas
        case gasPrice
        case gasUsed
        case nonce // Here we need to convert (from Int)]
        case shardingFlag
        case systemContract
        case via
        case timeStamp // Convert from timestamp
        case operations // Operations needs custom decoding
        case error // Only to throw
        case coin
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionCodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let blockNumber = try container.decode(Int.self, forKey: .blockNumber)
        let from = try container.decode(String.self, forKey: .from)
        let to = try container.decode(String.self, forKey: .to)
        let value = try container.decode(String.self, forKey: .value)
        let gas = try container.decode(String.self, forKey: .gas)
        let coin = try container.decode(Coin.self, forKey: .coin)
        let gasPrice = try container.decode(String.self, forKey: .gasPrice)
        let gasUsed = try container.decode(String.self, forKey: .gasUsed)
        let rawNonce = try container.decode(Int.self, forKey: .nonce)
        let shardingFlag = try container.decode(String.self, forKey: .shardingFlag)
        let systemContract = try container.decode(String.self, forKey: .systemContract)
        let via = try container.decode(String.self, forKey: .via)
        let timeStamp = try container.decode(String.self, forKey: .timeStamp)
        let error = try container.decodeIfPresent(String.self, forKey: .error)
        let operations = try container.decode([LocalizedOperationObject].self, forKey: .operations)

        guard
            let fromAddress = MoacAddress(string: from) else {
                let context = DecodingError.Context(codingPath: [TransactionCodingKeys.from],
                                                    debugDescription: "Address can't be decoded as a TrustKeystore.Address")
                throw DecodingError.dataCorrupted(context)
        }

        let state: TransactionState = {
            if error?.isEmpty == false {
                return .error
            }
            return .completed
        }()

        self.init(
            id: id,
            blockNumber: blockNumber,
            from: fromAddress.description,
            to: to,
            value: value,
            gas: gas,
            gasPrice: gasPrice,
            gasUsed: gasUsed,
            nonce: rawNonce,
            shardingFlag: shardingFlag,
            systemContract: systemContract,
            via: via,
            date: Date(timeIntervalSince1970: TimeInterval(timeStamp) ?? 0),
            coin: coin,
            localizedOperations: operations,
            state: state
        )
    }

    override static func primaryKey() -> String? {
        return "uniqueID"
    }

    var state: TransactionState {
        return TransactionState(int: self.internalState)
    }

    var toAddress: MoacAddress? {
        return MoacAddress(string: to)
    }

    var fromAddress: MoacAddress? {
        return MoacAddress(string: from)
    }

    var contractAddress: MoacAddress? {
        guard
            let operation = operation,
            let contract = operation.contract,
            let contractAddress = MoacAddress(string: contract) else {
                return .none
        }
        return contractAddress
    }
    
    var viaAddress: MoacAddress? {
        return MoacAddress(string: via)
    }
}

extension Transaction {
    var operation: LocalizedOperationObject? {
        return localizedOperations.first
    }
}
