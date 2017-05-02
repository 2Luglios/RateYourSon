//
//  ItemAvaliacao.swift
//  RateYourSon
//
//  Created by Ettore Luglio on 29/04/17.
//  Copyright © 2017 Tamadrum. All rights reserved.
//

import Foundation
import UIKit

class ItemAvaliacao: UITableViewCell {
    
    @IBOutlet weak var assunto: UILabel!
    @IBOutlet weak var status: UISegmentedControl!
    
    var avaliacao: Avaliacao!
    
    @IBAction func trocou(_ sender: UISegmentedControl) {
        if ( sender.selectedSegmentIndex == 0 ) { avaliacao.status = "feliz" }
        if ( sender.selectedSegmentIndex == 1 ) { avaliacao.status = "medio" }
        if ( sender.selectedSegmentIndex == 2 ) { avaliacao.status = "triste" }
        if ( sender.selectedSegmentIndex == 3 ) { avaliacao.status = "na" }
    }
}
