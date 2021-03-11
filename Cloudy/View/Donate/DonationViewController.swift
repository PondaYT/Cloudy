// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation
import UIKit

/// Specific reKairos donation reminder
class DonationViewController: UIViewController {

    /// Type for disappearing
    typealias ViewControllerDismissed = () -> Void

    /// Factory method
    static func create(completion: @escaping ViewControllerDismissed) -> DonationViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DonationViewController") as! DonationViewController
        vc.completion = completion
        return vc
    }

    /// Dismissed callback
    var completion: ViewControllerDismissed? = nil

    /// Gone
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        completion?()
    }

    /// Patreon pressed
    @IBAction func onPatreonPressed(_ sender: Any) {
        UIApplication.shared.open(Navigator.Config.Url.patreonReKairos)
        UserDefaults.standard.didDonateAlready = true
    }

    /// Paypal pressed
    @IBAction func onPayPalPressed(_ sender: Any) {
        UIApplication.shared.open(Navigator.Config.Url.paypalReKairos)
        UserDefaults.standard.didDonateAlready = true
    }

    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
