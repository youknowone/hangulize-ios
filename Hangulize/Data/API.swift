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
        call(jsonPath: "/", params: ["lang": code, "word": word]).map {
            data in
            APIResult(data: data)
        }
    }
}

struct APILanguage {
    let data: Any

    private var dict: [String: Any] {
        data as! [String: Any]
    }

    var code: String {
        dict["code"] as! String
    }

    var name: String {
        dict["name"] as! String
    }

    var label: String {
        dict["label"] as! String
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
    let data: Any

    private var dict: [String: Any] {
        data as! [String: Any]
    }

    var result: String {
        let x = (data as! [String: Any])["result"]!
        return x as! String
    }
}

final class HangulizeService: ObservableObject {
    @Published var languages: [APILanguage]

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
