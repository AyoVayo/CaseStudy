//
//  ViewController.swift
//  CaseStudy
//
//  Created by ali.ocal on 29.03.2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var personTableView: UITableView! {
        didSet {
            personTableView.register(UINib(nibName: String(describing: PersonTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PersonTableViewCell.self))
        }
    }
    
    var personArray: [Person] = []
    var currentPage: String? = nil
    var isLoading = false
    var didFinish = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        personTableView.dataSource = self
        personTableView.delegate = self
        
        loadPage(page: currentPage)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        personTableView.refreshControl = refreshControl
        
    }
    
    func loadPage(page: String?) {
        
        var retryCount = 0
        let maxRetryCount = 3
        let retryInterval: TimeInterval = 1
        
        func removeDuplicates(from people: inout [Person]) {
            var uniqueIds = [Int]()
            var index = 0
            while index < people.count {
                if uniqueIds.contains(people[index].id) {
                    people.remove(at: index)
                } else {
                    uniqueIds.append(people[index].id)
                    index += 1
                }
            }
        }

        func fetchData() {
            DataSource.fetch(next: page) { response, error in
                if let error {
                    if retryCount < maxRetryCount {
                        retryCount += 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryInterval) {
                            fetchData()
                        }
                    } else {
                        return print(error.errorDescription)
                    }
                }
                if let response {
                    self.personArray.append(contentsOf: response.people)
                    removeDuplicates(from: &self.personArray)
                    self.currentPage = response.next
                    if response.next == nil {
                        self.didFinish = true
                    }
                    self.isLoading = false
                    self.personTableView.reloadData()
                }
            }
        }
        guard !didFinish else {
            return
        }
        fetchData()
    }
    
    @objc private func refreshTable(_ sender: Any) {
        personArray.removeAll()
        currentPage = nil
        didFinish = false
        loadPage(page: currentPage)
        personTableView.refreshControl?.endRefreshing()
    }
    
    func createNoDataLabel() -> UILabel {
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: personTableView.bounds.size.width, height: personTableView.bounds.size.height))
        noDataLabel.text = "No one here :)"
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = .center
        
        return noDataLabel
    }
    
}

//MARK: TableView Delegate Methods

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if personArray.count == 0 {
            let noDataLabel = createNoDataLabel()
            personTableView.backgroundView = noDataLabel
            personTableView.separatorStyle = .none
            return 0
        }
        personTableView.backgroundView = nil
        personTableView.separatorStyle = .singleLine
        return personArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PersonTableViewCell.self), for: indexPath) as? PersonTableViewCell {
            if personArray.count >= indexPath.row {
                cell.setup(person: personArray[indexPath.row])
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !isLoading {
                isLoading = true
                loadPage(page: currentPage)
            }
        }
    }
}
