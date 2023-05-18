import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
	var searchResults: [Anime] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.delegate = self
		tableView.dataSource = self
		searchBar.delegate = self
		
		tableView.register(UINib(nibName: "AnimeTableViewCell", bundle: nil), forCellReuseIdentifier: "AnimeCell")
	}
	
	// MARK: - UITableViewDelegate and UITableViewDataSource methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeCell", for: indexPath) as! AnimeTableViewCell
		let anime = searchResults[indexPath.row]
		cell.configure(with: anime)
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		// Navigate to the anime details screen and pass the selected anime object
	}
	
	// MARK: - UISearchBarDelegate methods

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchText = searchBar.text, !searchText.isEmpty else {
			return
		}
		
		searchBar.resignFirstResponder()
		
		APIManager.shared.searchAnime(query: searchText, context: <#NSManagedObjectContext#>) { [weak self] (results, error) in
			guard let self = self else { return }
			if let results = results {
				self.searchResults = results
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			} else if let error = error {
				print("Error searching for anime: \(error.localizedDescription)")
			}
		}
	}
}
