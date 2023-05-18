//
//  SearchResultCell.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//

import UIKit

// This class represents a table view cell for displaying search results
class SearchResultCell: UITableViewCell {

	// Outlets for the name label, score label, and artwork image view in the cell
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var artworkImageView: UIImageView!
	
	// This method is called when the cell is loaded from the nib
    override func awakeFromNib() {
        super.awakeFromNib()
    }

	// This method is called when the cell's selected state is changed
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
	
	// This method configures the cell with an Anime object
	func configure(with anime: Anime) {
			nameLabel.text = anime.title
			scoreLabel.text = String(anime.score)

			if let imageUrlString = anime.imageUrl, let imageUrl = URL(string: imageUrlString) {
				artworkImageView.downloadImage(from: imageUrl)
			}
		}
}
