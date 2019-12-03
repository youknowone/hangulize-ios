//
//  API.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/10/18.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import UIKit

enum APIError: Error {
    case illFormedResponse
    case unexpectedResponse
}

class API {
    static let host = "https://hangulize.org"

    func call(jsonPath path: String, params: [String: String] = [:]) -> Result<Any, Error> {
        var comps = URLComponents(string: API.host)!
        comps.path = path
        comps.queryItems = params.map {
            key, value in
            URLQueryItem(name: key, value: value)
        }
        let url = comps.url!

        do {
            let data = try Data(contentsOf: url)
            let result = try JSONSerialization.jsonObject(with: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    func call(javascriptPath path: String, params: [String: String] = [:]) -> Result<String, Error> {
        var comps = URLComponents(string: API.host)!
        comps.path = path
        comps.queryItems = params.map {
            key, value in
            URLQueryItem(name: key, value: value)
        }
        let url = comps.url!

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                return .failure(APIError.unexpectedResponse)
            }
            return .success(string)
        } catch {
            return .failure(error)
        }
    }

    func languages() -> Result<[APILanguage], Error> {
        let result = call(jsonPath: "/langs")

        var data: [String: Any]
        do {
            guard let _data = try result.get() as? [String: Any] else {
                assert(false) // ill server response format
                return .failure(APIError.illFormedResponse)
            }
            data = _data
        } catch {
            return .failure(error)
        }
        let languages = (data["langs"] as! [Any]).map { APILanguage(data: $0 as! [String: String]) }.sorted(by: { $0.name < $1.name })
        if languages.isEmpty {
            return .failure(APIError.unexpectedResponse)
        }

        return .success(languages)
    }

    func hangulize(code: String, word: String) -> Result<APIHangulized, Error> {
        call(jsonPath: "/", params: ["lang": code, "word": word]).flatMap {
            data in
            guard let data = data as? [String: Any] else {
                return .failure(APIError.unexpectedResponse)
            }
            return .success(APIHangulized(data: data))
        }
    }

    static func retrieveData(from javascript: String) -> Result<[String: String], Error> {
        let regex = try! NSRegularExpression(pattern: #""[^"]+""#, options: [])
        let range = NSRange(location: 0, length: javascript.count) // practically safe
        let results = regex.matches(in: javascript, options: [], range: range)
        let stringAt: (Int) -> Result<String, Error> = {
            i in
            let r = results[i]
            let range = Range(r.range, in: javascript)!
            let data = "[\(javascript[range])]".data(using: .utf8)!
            do {
                guard let decoded = try JSONSerialization.jsonObject(with: data, options: []) as? [String] else {
                    return .failure(APIError.unexpectedResponse)
                }
                return .success(decoded[0])
            } catch {
                return .failure(error)
            }
        }

        var data = [String: String]()
        for i in stride(from: 0, to: results.count, by: 2) {
            do {
                let s1 = try stringAt(i).get()
                let s2 = try stringAt(i + 1).get()
                data[s1] = s2
            } catch {
                return .failure(error)
            }
        }

        return .success(data)
    }

    func shuffle(code: String) -> Result<APIShuffle, Error> {
        call(javascriptPath: "/shuffle.js", params: ["lang": code]).flatMap {
            js in
            API.retrieveData(from: js).flatMap {
                dict in
                dict["#word"].map { _ in
                    .success(APIShuffle(data: dict))
                } ?? .failure(APIError.unexpectedResponse)
            }
        }
    }
}

struct APIShuffle {
    let data: [String: String]

    var word: String {
        data["#word"]!
    }
}

struct APILanguage {
    let data: [String: Any]

    var code: String {
        data["code"] as! String
    }

    var name: String {
        data["name"] as! String
    }

    var label: String {
        data["label"] as! String
    }

    var iso639_1: String {
        data["iso639-1"] as! String
    }
}

extension APILanguage: Hashable {
    static func == (lhs: APILanguage, rhs: APILanguage) -> Bool {
        lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}

struct APIHangulized {
    let data: [String: Any]

    var result: String {
        let x = data["result"]!
        return x as! String
    }
}

final class HangulizeService {
    var languages: [APILanguage]

    let api = API()

    init?() {
        guard let langs = try? api.languages().get() else {
            return nil
        }
        languages = langs
    }

    func language(forCode code: String) -> APILanguage? {
        languages.first(where: { $0.code == code })
    }
}

var hangulize: HangulizeService! = HangulizeService()

class APIView<InputType, ResultType>: ObservableObject {
    @Published var updating: Bool = false
    @Published var success: Bool = false
    @Published var result: ResultType
    @Published var _resultDefault: () -> ResultType
    var _executeItem: DispatchWorkItem?

    init(default _default: @escaping () -> ResultType) {
        _resultDefault = _default
        result = _default()
    }
}

extension APIView where ResultType == String {
    convenience init() {
        self.init(default: { "" })
    }
}

enum APIViewClearPolicy {
    case trial
    case success
}

protocol APIViewSource {
    associatedtype InputType
    associatedtype ResultType
    associatedtype ViewType = APIView<InputType, ResultType>

    var clearPolicy: APIViewClearPolicy { get }

    func execute(with params: InputType) -> ResultType?
    func updateInBackground(with params: InputType, onSuccess: @escaping () -> Void)
}

extension APIViewSource where ViewType == APIView<InputType, ResultType> {
    func updateInBackground(with params: InputType, onSuccess: @escaping () -> Void = {}) {
        let zelf = self as! ViewType
        zelf.updating = true
        if clearPolicy == .trial {
            zelf.result = zelf._resultDefault()
        }
        if let item = zelf._executeItem {
            item.cancel()
        }
        var workItem: DispatchWorkItem!
        let _workItem = DispatchWorkItem {
            let result = self.execute(with: params)
            DispatchQueue.main.sync {
                if workItem.isCancelled {
                    return
                }
                defer {
                    zelf.updating = false
                    zelf._executeItem = nil
                }
                zelf.success = result != nil
                if let result = result {
                    zelf.result = result
                }
                onSuccess()
            }
        }
        workItem = _workItem

        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
        zelf._executeItem = workItem
    }
}

final class HangulizeView: APIView<(code: String, word: String), String> {}

extension HangulizeView: APIViewSource {
    typealias InputType = (code: String, word: String)
    typealias ResultType = String

    var clearPolicy: APIViewClearPolicy {
        .trial
    }

    func execute(with params: (code: String, word: String)) -> String? {
        try? hangulize.api.hangulize(code: params.code, word: params.word).map { $0.result }.get()
    }
}

final class ShuffleView: APIView<String, String> {}

extension ShuffleView: APIViewSource {
    typealias InputType = String
    typealias ResultType = String

    var clearPolicy: APIViewClearPolicy {
        .success
    }

    func execute(with params: String) -> String? {
        try? hangulize.api.shuffle(code: params).map { $0.word }.get()
    }
}

import AVFoundation
let speechSynthesizer = AVSpeechSynthesizer()
