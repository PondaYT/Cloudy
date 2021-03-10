//  Copyright © 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

class FortniteiPhoneTutorial: UIViewController {

    @IBOutlet var tutorialImageView:          UIImageView!
    @IBOutlet var tutorialTitle:              UILabel!
    @IBOutlet var tutorialDescription:        UITextView!
    @IBOutlet var nextTutorialDataButton:     UIButton!
    @IBOutlet var previousTutorialDataButton: UIButton!

    var tutorialImageData:       [UIImage] = []
    var tutorialTitleData:       [String]  = []
    var tutorialDescriptionData: [String]  = []

    var dataIndex = 0

    @IBAction func dismissTutorial() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func nextTutorialData() {

    }

    @IBAction func previousTutorialData() {

    }

}
