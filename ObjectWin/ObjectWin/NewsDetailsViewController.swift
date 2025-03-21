//
//  NewsDetailsViewController.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

import UIKit
import SafariServices
class NewsDetailsViewController: UIViewController {
    @IBOutlet weak var newsDetailsTable: UITableView!
    var newsDetails:Articles?
    //View Model Object
    private let viewModel = NewsViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News Details"
        registerTableView()
        getLikesandComments()
        // Do any additional setup after loading the view.
    }

    //Register Tableview
    func registerTableView() {
        newsDetailsTable.delegate = self
        newsDetailsTable.dataSource = self
        newsDetailsTable.register(UINib(nibName: "ListItemCell", bundle: nil), forCellReuseIdentifier: "ListItemCell")
    }
  
    func getLikesandComments() {
        guard let articleURL = newsDetails?.url else { return }
        APIManager.shared.fetchLikesAndComments(for: articleURL) { likes, comments, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
            } else {
                print("Likes: \(likes ?? 0), Comments: \(comments ?? 0)")
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//UItableview deleagte and data source
extension NewsDetailsViewController:UITableViewDelegate, UITableViewDataSource {
    
    //Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard newsDetails != nil else {
            return 0
        }
        return 1
    }
    //Populating data in tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListItemCell") as? ListItemCell else {
            return UITableViewCell()
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.readMoreButton.isHidden = false
        cell.readMoreHeight.constant = 35
        guard let newsDetails else {
            return cell
        }
        
        cell.configureData(listItem: newsDetails)
        return cell
    }
    //Make height dynamic based on content
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
//Custom delegate methods
extension NewsDetailsViewController:NewsDataUpdate,ReadMoreDelegate,SFSafariViewControllerDelegate {

    //Api data update
    func updateArticles() {
        DispatchQueue.main.async {
            self.newsDetailsTable.reloadData()
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
        guard newsDetails != nil else {
            return 
        }
        let selectedArticle = newsDetails
        guard let urlString = selectedArticle?.url, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self // Set delegate
        safariVC.modalPresentationStyle = .fullScreen
        present(safariVC, animated: true)
        
    }
    
    
}
