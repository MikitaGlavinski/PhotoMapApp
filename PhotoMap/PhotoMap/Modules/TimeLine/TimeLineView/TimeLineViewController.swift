//
//  TimeLineViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineViewInput: AnyObject {
    func showError(error: Error)
    func setupSectioList(sections: [TimeLineSection])
    func setSelectedCategories(categories: [Category])
}

class TimeLineViewController: UIViewController {
    
    var viewModel: TimeLineViewModelProtocol!
    private var sections = [TimeLineSection]()
    private var filteredSections = [TimeLineSection]()
    private var selectedCategories = [Category]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: CustomSearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.setSelectedCategories()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        addGestures()
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func showCategories(_ sender: Any) {
        viewModel.showCategories()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension TimeLineViewController: TimeLineViewInput {
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func setupSectioList(sections: [TimeLineSection]) {
        self.sections = sections
        filterSelectedCategories()
        tableView.reloadData()
    }
    
    func setSelectedCategories(categories: [Category]) {
        selectedCategories = categories
        filterSelectedCategories()
        tableView.reloadData()
    }
    
    private func filterSelectedCategories() {
        filteredSections = sections.compactMap({ section in
            var filteredRows = [TimeLineCellModel]()
            for row in section.rows {
                let category = Category.init(rawValue: row.category) ?? .friends
                if selectedCategories.contains(category) {
                    filteredRows.append(row)
                }
            }
            return TimeLineSection(title: section.title, rows: filteredRows)
        })
    }
}

extension TimeLineViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (searchBar.textField.text?.count ?? 0 > 0) || (selectedCategories.count > 0) ? filteredSections.count : sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searchBar.textField.text?.count ?? 0 > 0) || (selectedCategories.count > 0) ? filteredSections[section].rows.count : sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowModel = (searchBar.textField.text?.count ?? 0 > 0) || (selectedCategories.count > 0) ? filteredSections[indexPath.section].rows[indexPath.row] : sections[indexPath.section].rows[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell", for: indexPath) as? TimeLineCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCell(with: rowModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .light)
        label.textColor = .lightGray
        label.text = (searchBar.textField.text?.count ?? 0 > 0) || (selectedCategories.count > 0) ? filteredSections[section].title : sections[section].title
        label.frame = CGRect(x: 20, y: -5, width: 200, height: 40)
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
}

extension TimeLineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowModel = (searchBar.textField.text?.count ?? 0 > 0) || (selectedCategories.count > 0) ? filteredSections[indexPath.section].rows[indexPath.row] : sections[indexPath.section].rows[indexPath.row]
        viewModel.showImage(cellModel: rowModel)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TimeLineViewController: TimeLineCellDelegate {
    
    func loadImage(url: String, completion: @escaping (UIImage) -> ()) {
        viewModel.loadImage(url: url, completion: completion)
    }
}

extension TimeLineViewController: CustomSearchBarDelegate {
    
    func searchTextDidChange(searchBar: CustomSearchBar, text: String) {
        if text == "" {
            filterSelectedCategories()
        } else {
            filteredSections = sections.compactMap({ section in
                var filteredRows = [TimeLineCellModel]()
                for cell in section.rows {
                    let category = Category.init(rawValue: cell.category) ?? .friends
                    let selectCategoryValue = selectedCategories.count > 0 ? selectedCategories.contains(category) : true
                    if cell.infoLabelText.contains("#\(text)") && selectCategoryValue {
                        filteredRows.append(cell)
                    }
                }
                return TimeLineSection(title: section.title, rows: filteredRows)
            })
        }
        tableView.reloadData()
    }
}
