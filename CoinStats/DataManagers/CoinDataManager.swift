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
                .subscribe(
                    onNext: { (networkResponse) in
                        guard let data = strongSelf.parseDictionary(from: networkResponse),
                              let coins = strongSelf.parseCoins(from: data, with: nil) else {
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
        .observe(on: MainScheduler.instance)
    }
    
    func fetchAndUpdateAllCoinsData(with previousCoins: [Coin]) -> Observable<[Coin]> {
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
                .subscribe(
                    onNext: { (networkResponse) in
                        guard let data = strongSelf.parseDictionary(from: networkResponse),
                              let coins = strongSelf.parseCoins(from: data, with: previousCoins) else {
                            observer.onError(Error.parsing)
                            return
                        }
                        
                        observer.onNext(coins)
                        observer.onCompleted()
                    },
                    onError: { (error) in
                    
                    }
                )
                .disposed(by: strongSelf.bag)
            
            return Disposables.create {}
        }
        .observe(on: MainScheduler.instance)
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
    
    private func parseCoins(from initialDataDict: [AnyHashable : Any], with previousCoins: [Coin]?) -> [Coin]? {
        // Getting nested main dictionaries array
        guard  let arrayToDecode = initialDataDict[Constants.HttpBodyKeys.coins.rawValue] as? [Any] else {
            return nil
        }
             
        var retVal: [Coin]? = nil
        
        // Checking if the previous coins array was passed,
        // to parse objects with correct way
        if let previousCoins = previousCoins {
            let items = arrayToDecode.compactMap({ $0 as? [Any] }).compactMap({ Coin(from: $0, and: previousCoins) })
            if (!items.isEmpty) {
                retVal = items
            }
        }
        // Otherwise the fetched dictionary must be correctly serialized to JSON data object after object,
        // because there can be fetched NOT CORRECT objects from API
        else {
            let dictionaryArrayToDecode = arrayToDecode.compactMap({ $0 as? [AnyHashable : Any] })
            var itemsToAppend = [Coin]()
            
            for dictIter in dictionaryArrayToDecode {
                if let data = try? JSONSerialization.data(withJSONObject: dictIter,options: .prettyPrinted) {
                    do {
                        itemsToAppend.append(try JSONDecoder().decode(Coin.self, from: data))
                    }
                    catch {
                        print("Error while parsing: \(error).")
                    }
                }
            }
            
            if (!itemsToAppend.isEmpty) {
                retVal = itemsToAppend
            }
        }
        
        return retVal
    }
}
