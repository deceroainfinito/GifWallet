//
//  GiphyAPIClient.swift
//  GifWalletKit
//
//  Created by Jordi Serra i Font on 14/11/2018.
//  Copyright © 2018 Pierluigi Cifani. All rights reserved.
//

import Foundation
import Deferred

public class GiphyAPIClient: APIClient {
    public init() {
        let signature = Signature(name: "api_key", value: "kw7ABCKe5AfWxPu0qLcjaN7MpQdqAPES")
        super.init(environment: Giphy.Hosts.production, signature: signature)
    }
    
    public func fetchTrending() -> Task<Giphy.Responses.Page> {
        let request: Request<Giphy.Responses.Page> = requestForEndpoint(Giphy.API.trending)
        return self.perform(request)
    }
    
    public func searchGif(term: String) -> Task<Giphy.Responses.Page> {
        let request: Request<Giphy.Responses.Page> = requestForEndpoint(Giphy.API.search(term))
        return self.perform(request)
    }
}

public enum Giphy {
    enum Hosts: Environment {
        case production
        
        var baseURL: URL {
            switch self {
            case .production:
                return URL(string: "https://api.giphy.com")!
            }
        }
    }
    
    enum API: Endpoint {
        case trending
        case search(String)
        
        var path: String {
            switch self {
            case .trending:
                return "/v1/gifs/trending"
            case .search(let term):
                return "/v1/gifs/search?q=\(term)"
            }
        }
    }
    
    public enum Responses {
        public struct GIF: Decodable {
            public let id: String
            public let url: URL
            public let title: String
            private enum GIFKeys: String, CodingKey {
                case id = "id"
                case images = "images"
                case title = "title"
            }
            
            private enum ImagesKeys: String, CodingKey {
                case original = "original"
            }
            
            private enum ImageKeys: String, CodingKey {
                case url = "url"
            }
            
            init(id: String, url: URL, title: String) {
                self.id = id
                self.url = url
                self.title = title
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: GIFKeys.self)
                let id: String = try container.decode(String.self, forKey: .id)
                let title: String = try container.decode(String.self, forKey: .title)
                let imagesContainer = try container.nestedContainer(keyedBy: ImagesKeys.self, forKey: .images)
                let originalContainer = try imagesContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .original)
                let url: URL = try originalContainer.decode(URL.self, forKey: .url)
                self.init(id: id, url: url, title: title)
            }
        }

        public struct Page: Decodable {
            public let data: [GIF]
        }
    }
}
