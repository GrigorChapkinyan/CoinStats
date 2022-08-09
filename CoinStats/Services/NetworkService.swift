//
//  NetworkService.swift
//  CoinStats
//
//  Created by Grigor Chapkinyan on 09.08.22.
//

import Foundation
import RxSwift

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

enum HttpRequestError: Error {
    case unauthorize
    case serverError
    case invalidData
    case noInternetConnection
    case requestBodyIncorrect
    case unknown
}

typealias NetworkResponse = (data: Data?,headers: [AnyHashable : Any])

class NetworkService {
    func sendHttpRequest(urlString: String,httpMethod: HttpMethod,queryParametrs: [String:String]? = nil,httpHeaders: [String:String]? = nil,body: [String:Any]? = nil) -> Observable<NetworkResponse> {
        return Observable.create { [weak self] (observer) -> Disposable in
            var urlComponents = URLComponents(string: urlString)
            self?.configureQueryParams(urlComponents: &urlComponents, queryParametrs: queryParametrs)
            
            guard let url = urlComponents?.url else { observer.onError(HttpRequestError.requestBodyIncorrect); return Disposables.create() }
            
            var request = URLRequest(url: url)
            self?.configureHeaderFields(request: &request, headers: httpHeaders)
            
            request.httpMethod = httpMethod.rawValue
            
            if let body = body {
                let jsonData = try? JSONSerialization.data(withJSONObject: body,options: .sortedKeys)
                request.httpBody = jsonData
            }
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    if  let nsError = error as NSError?,
                        nsError.code == NSURLErrorNotConnectedToInternet {
                        observer.onError(HttpRequestError.noInternetConnection)
                    }
                    else {
                        observer.onError(error!)
                    }
                    return
                }
                
                guard   let httpResponse = response as? HTTPURLResponse,
                        200...300 ~= httpResponse.statusCode else {
                    self?.handleResponseNotValidStatusCode(observer: observer, response: response)
                    
                    return
                }
                
                let headers = self?.allHeadersFromResponse(response: response) ?? [ : ]
                
                observer.onNext(NetworkResponse(data: data,headers: headers))
                observer.onCompleted()
            }
            
            dataTask.resume()
            
            return Disposables.create {
                dataTask.cancel()
            }
        }
        .observe(on: MainScheduler.instance)
    }
    
    // MARK: Helpers

    private func configureHeaderFields(request: inout URLRequest,headers: [String:String]?) {
        guard let headers = headers else { return }
        
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    private func configureQueryParams(urlComponents:inout URLComponents?,queryParametrs: [String:String]?) {
        guard let queryParametrs = queryParametrs else { return }
        
        var queryItems = [URLQueryItem]()
        
        for param in queryParametrs {
            let newItem = URLQueryItem(name: param.key, value: param.value)
            queryItems.append(newItem)
        }
        
        urlComponents?.queryItems = queryItems
    }
    
    private func allHeadersFromResponse(response: URLResponse?) -> [AnyHashable : Any] {
        if let httpUrlResponse = response as? HTTPURLResponse {
            return httpUrlResponse.allHeaderFields
        }
        else {
            return [ : ]
        }
    }
    
    private func handleResponseNotValidStatusCode(observer: AnyObserver<NetworkResponse>,response: URLResponse?) {
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            if httpResponse.statusCode == 401 {
                observer.onError(HttpRequestError.unauthorize)
            }
            else if (400..<500 ~= httpResponse.statusCode) {
                observer.onError(HttpRequestError.invalidData)
            }
            else if (500...600 ~= httpResponse.statusCode) || (httpResponse.statusCode == 404) {
                observer.onError(HttpRequestError.serverError)
            }
            else {
                observer.onError(HttpRequestError.unknown)
            }
        }
        else {
            observer.onError(HttpRequestError.unknown)
        }
    }
}
