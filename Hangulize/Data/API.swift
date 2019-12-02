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

    func hangulize(code: String, word: String) -> Result<APIResult, Error> {
        call(jsonPath: "/", params: ["lang": code, "word": word]).flatMap {
            data in
            guard let data = data as? [String: Any] else {
                return .failure(APIError.unexpectedResponse)
            }
            return .success(APIResult(data: data))
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

    func shuffle(code: String) -> Result<String, Error> {
        call(javascriptPath: "/shuffle.js", params: ["lang": code]).flatMap {
            js in
            API.retrieveData(from: js).flatMap {
                dict in
                if let word = dict["#word"] {
                    return .success(word)
                } else {
                    return .failure(APIError.unexpectedResponse)
                }
            }
        }
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

struct APIResult {
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

final class Hangulized: ObservableObject {
    @Published var updating: Bool = false
    @Published var output: String = ""
    @Published var success: Bool = false

    func update(code: String, word: String) {
        updating = true
        output = ""
        DispatchQueue.global(qos: .userInitiated).async {
            let result = try? hangulize.api.hangulize(code: code, word: word).get()
            DispatchQueue.main.sync {
                defer {
                    self.updating = false
                }
                self.success = result != nil
                if let result = result {
                    self.output = result.result
                }
            }
        }
    }
}

import AVFoundation
let speechSynthesizer = AVSpeechSynthesizer()
