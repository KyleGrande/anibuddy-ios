//
//  APIManager.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//
protocol SettingsViewControllerDelegate: AnyObject {
	func didChangeFetchType(to fetchTop: Bool)
}

import Foundation
import CoreData

class APIManager {
	
	static let shared = APIManager()
	private let baseURL = "https://api.jikan.moe/v4"
	
	private init() {}
	
	// Function to search anime based on a given query
	func searchAnime(query: String, context: NSManagedObjectContext, completion: @escaping (Result<[Anime], Error>) -> Void) {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		let urlString = "\(baseURL)/anime?q=\(encodedQuery)&sfw=true&fields=mal_id,title,imageUrl,synopsis,type,episodes,score,startDate,endDate&page=1"
		guard let url = URL(string: urlString) else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
				return
			}
//			print("Printing data")
//			print(String(data: data, encoding: .utf8)) // Print the response data
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
				guard let results = json?["data"] as? [[String: Any]] else {
					completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No results found"])))
					return
				}
				
				let animes: [Anime] = results.compactMap { jsonAnime in
					guard let anime = Anime.createFromJSON(jsonAnime, context: context) else { return nil }
					return anime
				}
				
				context.performAndWait {
					do {
						try context.save()
					} catch {
						print("Error saving context: \(error.localizedDescription)")
					}
				}
				
				completion(.success(animes))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	
	// Function to fetch top Anime from API
	func fetchTopAnime(context: NSManagedObjectContext, completion: @escaping (Result<[Anime], Error>) -> Void) {
		let urlString = "\(baseURL)/top/anime?limit=50&page=1"
		guard let url = URL(string: urlString) else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
				return
			}
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
				guard let results = json?["data"] as? [[String: Any]] else {
					completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No results found"])))
					return
				}
				
				let animes: [Anime] = results.compactMap { jsonAnime in
					guard let anime = Anime.createFromJSON(jsonAnime, context: context) else { return nil }
					return anime
				}
				
				context.performAndWait {
					do {
						try context.save()
					} catch {
						print("Error saving context: \(error.localizedDescription)")
					}
				}
				
				completion(.success(animes))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	// Function to fetch current season Anime from API
	func fetchCurrentSeasonAnime(context: NSManagedObjectContext, completion: @escaping (Result<[Anime], Error>) -> Void) {
			let urlString = "\(baseURL)/seasons/now"
		guard let url = URL(string: urlString) else {
			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
				return
			}
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
				guard let results = json?["data"] as? [[String: Any]] else {
					completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No results found"])))
					return
				}
				
				let animes: [Anime] = results.compactMap { jsonAnime in
					guard let anime = Anime.createFromJSON(jsonAnime, context: context) else { return nil }
					return anime
				}
				
				context.performAndWait {
					do {
						try context.save()
					} catch {
						print("Error saving context: \(error.localizedDescription)")
					}
				}
				
				completion(.success(animes))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
}
