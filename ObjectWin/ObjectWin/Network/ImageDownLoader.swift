//
//  ImageDownLoader.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

import UIKit

class ImageDownLoader {
static let shared = ImageDownLoader()
private var imageCache = NSCache<NSURL, UIImage>()

private init() {}

func loadImage(from url: URL) async -> UIImage? {
    if let cachedImage = imageCache.object(forKey: url as NSURL) {
        return cachedImage
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            imageCache.setObject(image, forKey: url as NSURL)
            return image
        }
    } catch {
        print("Error loading image: \(error)")
    }
    return nil
}
}
