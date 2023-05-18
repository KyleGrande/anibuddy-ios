//
//  LibraryTableViewController.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//

import UIKit
import CoreData

class LibraryTableViewController: UITableViewController {
	
	// Array to store the list of favorite Anime objects.
	var favoriteAnimes: [Anime] = []
	
	// FetchedResultsController to fetch Anime objects from Core Data.
	var fetchedResultsController: NSFetchedResultsController<Anime>!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Register SearchResultCell
		let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
		tableView.register(cellNib, forCellReuseIdentifier: "SearchResultCell")

		// Configure the fetchedResultsController
		configureFetchedResultsController()
		  
		// Load favorite animes
		loadFavoriteAnimes()
	}
	
	// MARK: - Helper Functions

	// Function to configure FetchedResultsController.
	
	// Get the AppDelegate instance to access the PersistentContainer.
	func configureFetchedResultsController() {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		
		let context = appDelegate.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<Anime> = Anime.fetchRequest()
		
		// The favorite animes are sorted by their title.
		let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		// Only fetch the animes that are marked as favorite. (Not Needed by nice to have)
		fetchRequest.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
	}
	
	// Function to load favorite animes.
	func loadFavoriteAnimes() {
		do {
			// Perform the fetch request.
			try fetchedResultsController.performFetch()
			// Store the fetched animes in the favoriteAnimes array.
			favoriteAnimes = fetchedResultsController.fetchedObjects ?? []
			// Reload the table view to display the new data.
			tableView.reloadData()
		} catch {
			print("Failed to fetch favorite animes: \(error)")
		}
	}
	
	// Prepare for the segue transition to the DetailViewController.
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetailFromLibrary" {
			let detailViewController = segue.destination as! DetailViewController
			let indexPath = sender as! IndexPath
			let anime = favoriteAnimes[indexPath.row]
			detailViewController.anime = anime
		}
	}

}

// MARK: - Table view data source
extension LibraryTableViewController {

	// Define the number of rows in the table view.
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return favoriteAnimes.count
	}

	// Configure each cell in the table view.
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell

		// Configure the cell...
		let anime = favoriteAnimes[indexPath.row]
		cell.configure(with: anime)

		return cell
	}
	
	// Define what happens when a row is selected in the table view.
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		performSegue(withIdentifier: "ShowDetailFromLibrary", sender: indexPath)
	}

}

// MARK: - NSFetchedResultsControllerDelegate
extension LibraryTableViewController: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		loadFavoriteAnimes()
	}
}

