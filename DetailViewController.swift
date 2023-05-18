//
//  DetailViewController.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//


//SIMILAR TO CHAPTER 37 IN TEXTBOOK
import UIKit
import CoreData

// DetailViewController class, manages detail view of a selected Anime
class DetailViewController: UIViewController {
	
	// Anime object to be shown in detail
	var anime: Anime!
	var downloadTask: URLSessionDownloadTask?

	// Action to close the Detail View
	@IBAction func close() {
	  dismiss(animated: true, completion: nil)
	}
	
	// Outlets for UI elements
	@IBOutlet weak var popupView: UIView!
	@IBOutlet weak var artworkImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var soreLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var genreLabel: UILabel!
	@IBOutlet weak var favButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup UI
		popupView.layer.cornerRadius = 10
		let gestureRecognizer = UITapGestureRecognizer(
		  target: self,
		  action: #selector(close))
		gestureRecognizer.cancelsTouchesInView = false
		gestureRecognizer.delegate = self
		view.addGestureRecognizer(gestureRecognizer)
		
		// Fetch Anime from CoreData and update the UI
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			let context = appDelegate.persistentContainer.viewContext
			let fetchRequest: NSFetchRequest<Anime> = Anime.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "mal_id == %d", anime.mal_id)
				do {
					let results = try context.fetch(fetchRequest)
					if let existingAnime = results.first {
						anime = existingAnime
					}
				} catch {
					print("Failed to fetch Anime with mal_id \(anime.mal_id): \(error)")
				}
			}
		if anime != nil {
			updateUI() }
    }
	
	// Action to toggle favorite status of the Anime
	@IBAction func toggleFavorite(_ sender: UIButton) {
		   guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			   return
		   }
		   
		   let context = appDelegate.persistentContainer.viewContext
		   anime.isFavorite.toggle()
		   
		   do {
			   try context.save()
			   animateFavButton()
			   updateFavButtonTitle()
			   print("Anime '\(anime.title ?? "")' favorite status changed to: \(anime.isFavorite)")
		   } catch {
			   print("Failed to update favorite status: \(error)")
		   }
	   }
	
	
	// Update UI with Anime information
	func updateUI() {
		nameLabel.text = anime.title
		soreLabel.text = String(anime.score)
		typeLabel.text = anime.type
		genreLabel.text = String(anime.episodes)
		if let imageUrlString = anime.imageUrl, let imageUrl = URL(string: imageUrlString) {
				artworkImageView.downloadImage(from: imageUrl)
			}
		updateFavButtonTitle()
		}
	
	// Update favorite button title based on Anime's favorite status
	func updateFavButtonTitle() {
		if anime.isFavorite {
			favButton.setTitle("Unfavorite", for: .normal)
			favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
		} else {
			favButton.setTitle("Favorite", for: .normal)
			favButton.setImage(UIImage(systemName: "star"), for: .normal)
		}
		favButton.isEnabled = true
	}
	
	// Animate favorite button for a click effect
	func animateFavButton() {
		UIView.animate(withDuration: 0.1, animations: {
			self.favButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
		}, completion: { _ in
			UIView.animate(withDuration: 0.1, animations: {
				self.favButton.transform = CGAffineTransform.identity
			})
		})
	}
	

}

extension DetailViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
	_ gestureRecognizer: UIGestureRecognizer,
	shouldReceive touch: UITouch
  ) -> Bool {
	return (touch.view === self.view)
  }
}

