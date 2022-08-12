//
//  CoinDataManager.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation
import RxSwift

class CoinDataManager {
    // MARK: - Nested Types

    enum Error: Swift.Error {
        case unknown
        case noData
        case parsing
    }
    
    // MARK: - Nested Private Types
    
    private enum APIRequestType {
        case allCoinsInitialData
        case allCoinsUpdateData
    }
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    
    // MARK: - Public Properties
    
    static let shared: CoinDataManager = CoinDataManager()

    // MARK: - Initializers
    
    private init() {}

    // MARK: - Public API
    
    func fetchAllCoinsInitialData() -> Observable<[Coin]> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let strongSelf = self else {
                observer.onError(Error.unknown)
                return Disposables.create()
            }
            
            NetworkService
                .shared
                .sendHttpRequest(
                    urlString: Constants.APIEndpoint.baseUrl.rawValue + Constants.APIEndpoint.coins.rawValue,
                    httpMethod: .get,
                    queryParametrs: strongSelf.getRequestParams(for: .allCoinsInitialData),
                    httpHeaders: strongSelf.getRequestHeaders(for: .allCoinsInitialData))
                .observe(on: SerialDispatchQueueScheduler(qos: .default))
                .subscribe(
                    onNext: { (networkResponse) in
                        guard let dict = strongSelf.parseDictionary(from: networkResponse),
                              let coins = strongSelf.parseCoins(from: dict) else {
                            observer.onError(Error.parsing)
                            return
                        }
                        
                        observer.onNext(coins)
                        observer.onCompleted()
                    },
                    onError: { (error) in
                        observer.onError(error)
                    }
                )
                .disposed(by: strongSelf.bag)
            
            return Disposables.create {}
        }
        .observe(on: MainScheduler.asyncInstance)
    }
    
    func fetchAndUpdateAllCoinsData(with previousCoins: [Coin]) -> Observable<Void> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let strongSelf = self else {
                observer.onError(Error.unknown)
                return Disposables.create()
            }
            
            NetworkService
                .shared
                .sendHttpRequest(
                    urlString: Constants.APIEndpoint.baseUrl.rawValue + Constants.APIEndpoint.coins.rawValue,
                    httpMethod: .get,
                    queryParametrs: strongSelf.getRequestParams(for: .allCoinsUpdateData),
                    httpHeaders: strongSelf.getRequestHeaders(for: .allCoinsUpdateData))
                .observe(on: SerialDispatchQueueScheduler(qos: .default))
                .subscribe(
                    onNext: { (networkResponse) in
                        guard let dict = strongSelf.parseDictionary(from: networkResponse),
                              strongSelf.updateCoins(from: dict, with: previousCoins) else {
                            observer.onError(Error.parsing)
                            return
                        }
                        
                        observer.onCompleted()
                    },
                    onError: { (error) in
                    
                    }
                )
                .disposed(by: strongSelf.bag)
            
            return Disposables.create {}
        }
        .observe(on: MainScheduler.asyncInstance)
    }
    
    // MARK: - Private API
    
    private func getRequestHeaders(for requestType:APIRequestType) -> [String:String]? {
        return Constants.requestJsonHeaders
    }
    
    private func getRequestParams(for requestType:APIRequestType) -> [String:String]? {
        var retVal = [String:String]()
        
        switch requestType {
            case .allCoinsInitialData:
                retVal.merge(dict: ["response-type" : "array"])
            
            case .allCoinsUpdateData:
                retVal.merge(dict: ["responseType" : "array"])
        }
        
        return retVal
    }
    
    private func parseDictionary(from networkResponse: NetworkService.Response) -> [AnyHashable : Any]? {
        guard   let data = networkResponse.data,
                let dict = try? JSONSerialization.jsonObject(with: data) as? [AnyHashable : Any] else { return nil }
        
        return dict
    }
    
    private func parseCoins(from dictionary:[AnyHashable:Any]) -> [Coin]? {
        // Getting nested main dictionaries array
        guard  let dictionaryArrayToDecode = dictionary[Constants.HttpBodyKeys.coins.rawValue] as? [[AnyHashable : Any]] else {
            return nil
        }
             
        var retVal = [Coin]()

        // Iterating trough each dictionary and parsing,
        // becuase there can be single objects
        // which parsing may be completed with failure
        for dictIter in dictionaryArrayToDecode {
            if let data = try? JSONSerialization.data(withJSONObject: dictIter,options: .prettyPrinted) {
                do {
                    retVal.append(try JSONDecoder().decode(Coin.self, from: data))
                }
                catch {
                    print("Error while parsing: \(error).")
                }
            }
        }
        
        return retVal
    }
    
    private func updateCoins(from updatedDataDict: [AnyHashable : Any], with previousCoins: [Coin]) -> Bool {
        // Getting nested main array
        guard  let arrayOfUpdatedData = updatedDataDict[Constants.HttpBodyKeys.coins.rawValue] as? [[Any]] else {
            return false
        }
             
        // Iterating trough each coin,
        // And updating the price
        for (i,_) in previousCoins.enumerated() {
            previousCoins[i].updatePrice(from: arrayOfUpdatedData)
        }
        
        return true
    }
}
