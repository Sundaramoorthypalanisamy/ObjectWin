//
//  APIManager.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case requestFailed(Error)
}

class APIManager {
    static let shared = APIManager()

    private init() {} // Singleton instance

    func fetchData<T: Codable>(from urlString: String, responseType: T.Type, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
    }
    
    func getArticleID(from urlString: String) -> String {
        guard let url = URL(string: urlString) else { return "" }
        let articleID = url.host! + url.path
        return articleID.replacingOccurrences(of: "/", with: "-")
    }
    
    func fetchLikesAndComments(for articleURL: String, completion: @escaping (Int?, Int?, Error?) -> Void) {
        let articleID = getArticleID(from: articleURL)
        
        let likesURL = URL(string: "https://cn-news-info-api.herokuapp.com/likes/\(articleID)")!
        let commentsURL = URL(string: "https://cn-news-info-api.herokuapp.com/comments/\(articleID)")!
        
        let dispatchGroup = DispatchGroup()
        
        var likesCount: Int?
        var commentsCount: Int?
        var fetchError: Error?
        
        // Fetch Likes
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: likesURL) { data, _, error in
            if let data = data {
                likesCount = try? JSONDecoder().decode(Int.self, from: data)
            }
            if error != nil { fetchError = error }
            dispatchGroup.leave()
        }.resume()
        
        // Fetch Comments
        dispatchGroup.enter()
        URLSession.shared.dataTask(with: commentsURL) { data, _, error in
            if let data = data {
                commentsCount = try? JSONDecoder().decode(Int.self, from: data)
            }
            if error != nil { fetchError = error }
            dispatchGroup.leave()
        }.resume()
        
        // Notify when both requests complete
        dispatchGroup.notify(queue: .main) {
            completion(likesCount, commentsCount, fetchError)
        }
    }
}
