//
//  AlbumListCell.swift
//  PhotoPicker
//
//  Created by wave on 2018/11/13.
//  Copyright © 2018 wave. All rights reserved.
//

import UIKit

class AlbumListCell: UITableViewCell {


    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectedCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none;
    }
//   
}
