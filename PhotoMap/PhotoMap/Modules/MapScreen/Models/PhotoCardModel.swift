//
//  PhotoCardModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/3/21.
//

import Foundation
import UIKit

enum Category: String {
    case friends = "FRIENDS"
    case nature = "NATURE"
    case standart = "DEFAULT"
}

struct PhotoCardModel {
    var image: UIImage
    var date: Double
    var stringDate: String
    var category: Category
    var text: String
    
    init(
        image: UIImage,
        date: Double,
        stringDate: String,
        category: Category,
        text: String
    ) {
        self.image = image
        self.date = date
        let convertDate = Date(timeIntervalSince1970: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d'th,' yyyy '-' HH:mm 'pm'"
        self.stringDate = formatter.string(from: convertDate)
        self.category = category
        self.text = text
    }
}
