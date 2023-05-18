//
//  UIImageView+DownloadImage.swift
//  Anibuddy
//
//  Created by Kyle Grande.
//


//SIMILAR IF NOT EXACT CODE FROM TEXTBOOK IN CHAPTER 36
import UIKit
import Foundation

extension UIImageView {
	func downloadImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				print("Error downloading image: \(error.localizedDescription)")
				completion?(nil)
				return
			}
			
			guard let data = data, let image = UIImage(data: data) else {
				print("Error converting data to image")
				completion?(nil)
				return
			}
			
			DispatchQueue.main.async {
				self.image = image
				completion?(image)
			}
		}.resume()
	}
	
	func downloadImage(from urlString: String, completion: ((UIImage?) -> Void)? = nil) {
		guard let url = URL(string: urlString) else {
			print("Error creating URL from string")
			completion?(nil)
			return
		}
		downloadImage(from: url, completion: completion)
	}
}
