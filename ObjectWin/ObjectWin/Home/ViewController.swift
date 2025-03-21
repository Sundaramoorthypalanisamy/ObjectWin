//
//  ViewController.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

import UIKit
import SafariServices
class ViewController: UIViewController {
    //UITableview
    @IBOutlet weak var newsPostTable: UITableView!
    //View Model Object
    private let viewModel = NewsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NEWS"
        registerTableView()
        setupViewModel()
        // Do any additional setup after loading the view.
    }

    //Register Tableview
    func registerTableView() {
        newsPostTable.delegate = self
        newsPostTable.dataSource = self
        newsPostTable.register(UINib(nibName: "ListItemCell", bundle: nil), forCellReuseIdentifier: "ListItemCell")
    }
    //Call API to load data
    private func setupViewModel() {
        viewModel.deleagte = self
        viewModel.fetchNews()
    }
 
}
//UItableview deleagte and data source
extension ViewController:UITableViewDelegate, UITableViewDataSource {
    
    //Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    //Populating data in tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemCell") as? ListItemCell else {
            return UITableViewCell()
        }
        if viewModel.articles.count > indexPath.row {
            let article = viewModel.articles[indexPath.row]
            cell.readMoreButton.isHidden = true
            cell.readMoreHeight.constant = 0
            cell.indexPath = indexPath
            cell.delegate = self
            cell.readMoreButton.isHidden = true
            cell.configureData(listItem: article)
        }
        return cell
    }
    //Make height dynamic based on content
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.articles.count > indexPath.row {
            let article = viewModel.articles[indexPath.row]
            if let detailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsViewController") as? NewsDetailsViewController {
                detailsViewController.newsDetails = article
                self.navigationController?.pushViewController(detailsViewController, animated: true)
            }
        }
    }
}

//Custom delegate methods
extension ViewController:NewsDataUpdate,ReadMoreDelegate,SFSafariViewControllerDelegate {

    //Api data update
    func updateArticles() {
        DispatchQueue.main.async {
            self.newsPostTable.reloadData()
        }
    }
    //API error handling
    func errorHandling(errorMessage: String) {
        PreferenceManager.shared.errorHandling(errorMessage: errorMessage, currentController: self)
    }
    // Delegate method to detect when SafariViewController is closed
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("SafariViewController closed")
        dismiss(animated: true) // Dismiss the Safari View
    }
    //Read more action
    func readmoreAction(readMoreIndex: IndexPath) {
        let selectedArticle = viewModel.articles[readMoreIndex.row]
        guard let urlString = selectedArticle.url, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self // Set delegate
        safariVC.modalPresentationStyle = .fullScreen
        present(safariVC, animated: true)
        
    }
    
    
}
