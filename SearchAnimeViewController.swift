//
//  SearchAnimeViewController.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//


//SIMILAR TO SEARCH APP IN TEXTBOOK SPECIFICALLY 35
import UIKit
import CoreData

class SearchAnimeViewController: UIViewController, SettingsViewControllerDelegate {

	// Outlets for search bar and table view
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	// Variable to keep track of search status and results
	var isSearchActive = false
	var searchResults: [Anime] = []
	
	// Variable to hold fetch setting value
	var fetchTop: Bool = UserDefaults.standard.bool(forKey: "fetchTop")

	// Get the context of CoreData from AppDelegate
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// I left this in case it was needed for testing
		// removeAllAnimeFromCoreData()
		
		// Set up the tableView and searchBar
		tableView.contentInset = UIEdgeInsets(top: 51, left: 0, bottom: 0, right: 0)
		searchBar.delegate = self
		tableView.dataSource = self
		let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: "SearchResultCell")
		// tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnimeCell")
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 44
		tableView.delegate = self

		// Fetch the top anime or the current season anime when the view loads
		didChangeFetchType(to: fetchTop)

		// Set self as delegate for all SettingsViewController instances in tabBarController
		if let tabBarController = tabBarController,
		   let viewControllers = tabBarController.viewControllers {
			for viewController in viewControllers {
				if let settingsViewController = viewController as? SettingsViewController {
					settingsViewController.delegate = self
				}
			}
		}
	}
	
	//this was left in case it was needed for testing
	func removeAllAnimeFromCoreData() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}

		let context = appDelegate.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Anime.fetchRequest()
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

		do {
			try context.execute(batchDeleteRequest)
			try context.save()
			print("Successfully removed all anime from Core Data.")
		} catch let error {
			print("Failed to remove all anime from Core Data: \(error)")
		}
	}

	// Function to handle change in fetch type
	func didChangeFetchType(to fetchTop: Bool) {
		
		// Set the fetchTop variable and store it in UserDefaults
		self.fetchTop = fetchTop
		UserDefaults.standard.set(fetchTop, forKey: "fetchTop")

		// Fetch either top anime or current season anime based on fetchTop variable
		if fetchTop {
			APIManager.shared.fetchTopAnime(context: context) { [weak self] result in
				DispatchQueue.main.async {
					switch result {
					case .success(let animes):
						self?.searchResults = animes
						self?.tableView.reloadData()
					case .failure(let error):
						print("Error fetching top anime: \(error.localizedDescription)")
					}
				}
			}
		} else {
			APIManager.shared.fetchCurrentSeasonAnime(context: context) { [weak self] result in
				DispatchQueue.main.async {
					switch result {
					case .success(let animes):
						self?.searchResults = animes
						self?.tableView.reloadData()
					case .failure(let error):
						print("Error fetching current season anime: \(error.localizedDescription)")
					}
				}
			}
		}
	}
	
	// Prepare for segue to the detail view controller
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
			if segue.identifier == "ShowDetail" {
				// Pass the selected anime to the detail view controller
				let detailViewController = segue.destination as! DetailViewController
				let indexPath = sender as! IndexPath
				let anime = searchResults[indexPath.row]
				detailViewController.anime = anime
			}
		}
}

// This extension adds UISearchBarDelegate methods to the SearchAnimeViewController
extension SearchAnimeViewController: UISearchBarDelegate {
	
	// This method is called whenever the text in the search bar is changed
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		// Trim the search text to remove any leading/trailing whitespace or newlines
		let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		if query.isEmpty {
			// If the search bar is empty, clear the search results and fetchTop
			isSearchActive = false
			searchResults = []
			didChangeFetchType(to: fetchTop)
		} else {
			// Perform the search with the query
			isSearchActive = true
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				APIManager.shared.searchAnime(query: query, context: self.context) { [weak self] result in
					DispatchQueue.main.async {
						// Process the result of the search
						switch result {
						// If the search was successful, update the search results and reload the table view data
						case .success(let animes):
							self?.searchResults = animes
							self?.tableView.reloadData()
						case .failure(let error):
							// If the search failed
							print("Error fetching search results: \(error.localizedDescription)")
						}
					}
				}
			}
		}
	}
	
	// This method is called when the search button on the keyboard is clicked
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		// Dismiss the keyboard when the search button is clicked
		searchBar.resignFirstResponder()
	}
}

// This extension adds UITableViewDelegate methods to the SearchAnimeViewController
extension SearchAnimeViewController: UITableViewDelegate {
	
	// This method is called when a row in the table view is selected
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Deselect the row and perform a segue to the detail view controller, passing the index path as the sender
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: "ShowDetail", sender: indexPath)
	}
}

// This extension adds UITableViewDataSource methods to the SearchAnimeViewController
extension SearchAnimeViewController: UITableViewDataSource {
	
	// This method returns the number of rows in the table view, which is the same as the number of search results
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}
	
	// This method returns the cell for a specific row in the table view
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Dequeue a reusable cell from the table view
		let cellIdentifier = "SearchResultCell"
		let cell = tableView.dequeueReusableCell(
			withIdentifier: cellIdentifier,
			for: indexPath) as! SearchResultCell

		// Get the anime for the current row
		let anime = searchResults[indexPath.row]

		// Configure the cell with the anime
		cell.configure(with: anime)

		return cell
	}
}
