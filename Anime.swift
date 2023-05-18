//
//  Anime.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//

import Foundation
import CoreData

extension Anime {
	static func createFromJSON(_ json: [String: Any], context: NSManagedObjectContext) -> Anime? {
		guard let mal_id = json["mal_id"] as? Int64,
			  let title = json["title_english"] as? String,
			  let images = json["images"] as? [String: Any],
			  let jpgImages = images["jpg"] as? [String: Any],
			  let imageUrl = jpgImages["large_image_url"] as? String,
			  let synopsis = json["synopsis"] as? String,
			  let type = json["type"] as? String,
			  let episodes = json["episodes"] as? Int64,
			  let score = json["score"] as? Double
				
		else {
			return nil
		}

		let anime = Anime(context: context)
		anime.mal_id = mal_id
		anime.title = title
		anime.imageUrl = imageUrl
		anime.synopsis = synopsis
		anime.type = type
		anime.episodes = episodes
		anime.score = score
		anime.isFavorite = false
		return anime
	}
}
