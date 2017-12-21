//
//  TVShow.swift
//  TV-Show-Track
//
//  Created by Brian Lim on 1/26/16.
//  Copyright © 2016 codebluapps. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class TVShow: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func setMovieImage(_ image: UIImage) {
        let data = UIImagePNGRepresentation(image)
        self.backgroundImg = data
    }
    
    func getMovieImage() -> UIImage {
        let img = UIImage(data: self.backgroundImg! as Data)
        return img!
    }

}
