//
//  PhotoCollectionViewCell.swift
//  FlickrTest
//
//  Created by OkuderaYuki on 2016/12/17.
//  Copyright © 2016年 YukiOkudera. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var imageURLString = ""
}
