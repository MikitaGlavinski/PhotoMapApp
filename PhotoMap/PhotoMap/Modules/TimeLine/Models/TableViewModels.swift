//
//  TableViewModels.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import Foundation

struct TimeLineSection {
    var title: String
    var rows: [TimeLineCellModel]
    
    init(title: String, rows: [TimeLineCellModel]) {
        self.title = title
        self.rows = rows
    }
}

struct TimeLineCellModel {
    var id: String
    var imageUrl: String
    var infoLabelText: String
    var date: Double
    var secondaryLabelText: String
    var sectionTitle: String
    
    init(id: String, imageUrl: String, text: String, date: Double, stringDate: String, sectionTitle: String) {
        self.id = id
        self.imageUrl = imageUrl
        self.infoLabelText = text
        self.date = date
        self.secondaryLabelText = stringDate
        self.sectionTitle = sectionTitle
    }
    
    init(photoRestModel: PhotoRestModel) {
        self.id = photoRestModel.id
        self.imageUrl = photoRestModel.imageUrl
        self.infoLabelText = photoRestModel.text
        self.date = photoRestModel.date
        let date = Date(timeIntervalSince1970: photoRestModel.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yy"
        self.secondaryLabelText = formatter.string(from: date) + " / \(photoRestModel.category)"
        formatter.dateFormat = "MMMM yyyy"
        self.sectionTitle = formatter.string(from: date)
    }
}
