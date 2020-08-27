//
//  BikingContainer.swift
//  assign4
//
//  Created by Gabe Lavarte on 4/7/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import Foundation

//OUR MODEL FOR BIKING RIDE DATA.

//For now it will contain all the placeholder labels that have been encoded even though
//they don't have to. Eventually, we will be encoding actual biking paths gps paths.

struct GPXPoint: Codable {
    var latitude: Double
    var longitude: Double
    var time: Date
}

struct GPXSegment: Codable {
    var coords : [GPXPoint]
}

struct GPXTrack : Codable {
    var name : String
    var link : String
    var time : Date
    var segments : [GPXSegment] = []
    var distance = "-"
}

class BikingContainer : Codable {
    var track: GPXTrack?
    
    init() {
        track = GPXTrack(name: "",
                         link: "",
                         time: Date(),
                         segments: [],
                         distance: "")
    }
    
    init?(json: Data) {
        if let decoded = try? JSONDecoder().decode(BikingContainer.self, from: json) {
            track = decoded.track
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
}
