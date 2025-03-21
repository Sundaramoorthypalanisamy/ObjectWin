//
//  NewsViewModel.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

protocol NewsDataUpdate:AnyObject {
    func updateArticles()
    func errorHandling(errorMessage:String)
}

class NewsViewModel {
    var articles: [Articles] = []
    var onNewsUpdated: (() -> Void)?
    weak var deleagte:NewsDataUpdate?
    private let apiURL = baseURL + APIKey

    //API call to fetch data
    func fetchNews() {
        APIManager.shared.fetchData(from: apiURL, responseType: News_List_Data.self) { [weak self] result in
            switch result {
            case .success(let newsResponse):
                self?.articles = newsResponse.articles ?? []
                self?.deleagte?.updateArticles()
            case .failure(let error):
                print("Failed to fetch news: \(error)")
                self?.deleagte?.errorHandling(errorMessage: "Failed to fetch news: \(error)")
            }
        }
    }
}
