// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Branch
import RealmSwift

import TrustCore
import PromiseKit
import BigInt
import APIKit
import JSONRPCKit
import enum Result.Result
import TrustKeystore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!
    //This is separate coordinator for the protection of the sensitive information.
    lazy var protectionCoordinator: ProtectionCoordinator = {
        return ProtectionCoordinator()
    }()
    let urlNavigatorCoordinator = URLNavigatorCoordinator()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        let realm = try! Realm(configuration: sharedMigration.config)
        let walletStorage = WalletStorage(realm: realm)
        let keystore = MoacKeystore(storage: walletStorage)

        coordinator = AppCoordinator(window: window!, keystore: keystore, navigator: urlNavigatorCoordinator)
        coordinator.start()

        if !UIApplication.shared.isProtectedDataAvailable {
            fatalError()
        }

        protectionCoordinator.didFinishLaunchingWithOptions()
        urlNavigatorCoordinator.branch.didFinishLaunchingWithOptions(launchOptions: launchOptions)
        
        enum Purpose {
            case balance
            case getNonce
            case sign
            case sendUnsignedTx
            case sendSignedTx
        }
        let addrOfBalanceCheck = "0xd04967d333fe17fe2707186608e5fc9d1447310c"
        let receivingTestnetAddr = "0x4c18080dd971ffeb4bc32097353741deae9685f3"
        let hashOfTxToInspect = "0x14138b41d26b2925d3b9b66d916cf41dcd62b37756db98fd1d75b66ef1a122eb"
        let contractAddrToCall = "0x574195ecFfDE7c86D4387B04ad1c5aefe1e40383"
        
        let contractJsonStr = "[{\"constant\":false,\"inputs\":[{\"name\":\"x\",\"type\":\"uint256\"}],\"name\":\"set\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"get\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
        let microChainAddressStr = "0xA4A1A503a02077146C620cb431B589a9d1DA55B6"
        let scsTxHash = "0x53bfd4754adc408f0d03b37161936423f523fd007248d182a40325918a797081"
        var nonce = BigInt(0)
        let i = Purpose.sendSignedTx

            switch i {
            case .balance:
                break
//                let request = MoacServiceRequest(for: .moacLocalPrivate, batch: BatchFactory().create(BalanceRequest(address: addrOfBalanceCheck)))
//                Session.send(request) { result in
//                    switch result {
//                    case .success(let balance):
//                        if self.server == .moacLocalPrivate {
//                            NSLog("######  \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) balance: \(balance)")
//                        } else {
//                            NSLog("######  \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) balance: \(balance)")
//                        }
//                        seal.fulfill(balance.value)
//                    case .failure(let error):
//                        NSLog("######  FAIL: \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck)")
//                        seal.reject(error)
//                    }
//                }
            case .getNonce:
                let request = MoacServiceRequest(for: .moacLocalPrivate, batch: BatchFactory().create(GetTransactionCountRequest(
                    address: addrOfBalanceCheck,
                    state: "latest"
                )))
                Session.send(request) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let count):
                        nonce = count
                        NSLog("######  OK: \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) nonce: \(nonce)")
                    case .failure(let error):
                        NSLog("######  FAIL: \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) nonce")
                    }
                }
            case .sendSignedTx:
                let mainAccount = keystore.wallets[0].accounts[0]
                keystore.exportPrivateKey(account: mainAccount) { [weak self] result in
                    switch result {
                    case .success(let privateKey):
                        let pKey = privateKey
                        
                        func signTransaction(_ transaction: SignTransaction) -> Result<Data, KeystoreError> {
                            let signer: Signer
                            if transaction.chainID == 0 {
                                signer = HomesteadSigner()
                            } else {
                                signer = EIP155Signer(chainId: BigInt(transaction.chainID))
                            }
                            
                            do {
                                let hash = signer.hash(transaction: transaction)
                                
                                let signature = Crypto.sign(hash: hash, privateKey: pKey)
                                let (r, s, v) = signer.values(transaction: transaction, signature: signature)
                                let data = RLP.encode([
                                    transaction.nonce,
                                    transaction.systemContract,
                                    transaction.gasPrice,
                                    transaction.gasLimit,
                                    transaction.to?.data ?? Data(),
                                    transaction.value,
                                    transaction.data,
                                    transaction.shardingFlag,
                                    transaction.via?.data ?? Data(),
                                    v, r, s,
                                    ])!
                                return .success(data)
                            }
                            return .failure(.failedToSignTransaction)
                        }
                        
                        let tx = SignTransaction(
                            value: BigInt(10000000000),
                            account: mainAccount,
                            to: MoacAddress(string: "0xe278416fce82f2992ba7147f01d9400163738da4"),
                            nonce: nonce,
                            data: Data(),
                            gasPrice: BigInt(200000),
                            gasLimit: BigInt(9000000),
                            chainID: 237,
                            shardingFlag: BigInt(0),
                            systemContract: BigInt(0),
                            via: MoacAddress(string: "0x"),
                            localizedObject: nil
                        )
                        let signedTransaction = signTransaction(tx)
                        
                        switch signedTransaction {
                        case .success(let data):
                            let dataHex = data.hexEncoded
                            let request = MoacServiceRequest(for: .moacLocalPrivate, batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: dataHex)))
                            Session.send(request) { result in
                                NSLog("######  sendSignedTx: \(request)")
                                switch result {
                                case .success:
                                    NSLog("######  \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) nonce: \(nonce) result: \(result)")
                                case .failure(let error):
                                    NSLog("######  FAIL: error: \(error.prettyError)")
                                }
                            }
                        case .failure(let error):
                            NSLog("######  FAIL: \(RPCServer.moacLocalPrivate.rpcURL) account: \(addrOfBalanceCheck) send signed tx")
                        }
                    case .failure(let error):
                        NSLog("FAIL: private key not exported")
                    }
                }
                
                
            default:
                NSLog("###### \(i) not impleted.")
            }
        
        
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        coordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        protectionCoordinator.applicationWillResignActive()
        Lock().setAutoLockTime()
        CookiesStore.save()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        protectionCoordinator.applicationDidBecomeActive()
        CookiesStore.load()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        protectionCoordinator.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        protectionCoordinator.applicationWillEnterForeground()
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard {
            return false
        }
        return true
    }

//    func application(
//        _ application: UIApplication,
//        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        Branch.getInstance().handlePushNotification(userInfo)
//    }

    // Respond to URI scheme links
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return urlNavigatorCoordinator.application(app, open: url, options: options)
    }

    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
}
