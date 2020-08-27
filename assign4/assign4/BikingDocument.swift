//
//  Document.swift
//  assign4
//
//  Created by Gabe Lavarte on 4/7/20.
//  Copyright © 2020 Gabe Lavarte. All rights reserved.
//

import UIKit

class BikingDocument: UIDocument {
    
    var container: BikingContainer?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return container?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            container = BikingContainer(json: data)
        }
    }
}

