//
//  PhotoDetail.swift
//  wooqer
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//
import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoState: Int, Codable {
    case new, sizeFetched, downloaded, failed
}
struct PhotosResult: Decodable {
    var photos: [Photo]?
    enum CodingKeys: String, CodingKey {
        case photos
        enum PhotosCodingKey: String, CodingKey {
            case photo
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let photosArr = try container.nestedContainer(keyedBy: CodingKeys.PhotosCodingKey.self, forKey: .photos)
        photos = try photosArr.decode([Photo].self, forKey: .photo)
    }
}
class Photo: Decodable {
    let id: String
    var url: URL?
    var state: PhotoState! = PhotoState.new
    enum CodingKeys: String, CodingKey {
        case id
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        state = PhotoState.new
    }
}

//MARK: - Decoding sizing classes
struct SizeMain: Decodable {
    var correctSize: Size?
    enum CodingKeys: String, CodingKey {
        case sizes
        enum SizeCodingKey: String, CodingKey {
            case size
        }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sizes = try container.nestedContainer(keyedBy: CodingKeys.SizeCodingKey.self, forKey: .sizes)
        let sizeArray = try sizes.decode([Size].self, forKey: .size)
        for size in sizeArray {
            if size.label == "Large Square" {
                correctSize = size
                break
            }
        }
    }
}
struct Size: Decodable {
    let source: URL
    let label: String
}
