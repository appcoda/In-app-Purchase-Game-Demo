//
//  ViewController.swift
//  FakeGame
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var overlayView: UIView!
    
    
    // MARK: - Properties
    
    var viewModel = ViewModel()
    
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureTableView()
        
        overlayView.isHidden = true
        viewModel.delegate = self
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the ViewModel object that the View part is ready.
        viewModel.viewDidSetup()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .lightContent
        } else {
            // Fallback on earlier versions
            return .default
        }
    }
    
    
    // MARK: - Custom Methods
    
    func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.backgroundColor = .clear
        self.tableView.isScrollEnabled = false
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.register(UINib(nibName: "ConsumablesCell", bundle: nil), forCellReuseIdentifier: "consumablesCell")
        self.tableView.register(UINib(nibName: "NonConsumablesCell", bundle: nil), forCellReuseIdentifier: "nonConsumablesCell")
    }
    
    
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "FakeGame", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - IBAction Methods
    
    @IBAction func restorePurchases(_ sender: Any) {
        viewModel.restorePurchases()
    }
    
    
    // MARK: - Methods To Implement
    
    func showAlert(for product: SKProduct) {
        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
        
        let alertController = UIAlertController(title: product.localizedTitle,
                                                message: product.localizedDescription,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Buy now for \(price)", style: .default, handler: { (_) in
            
            if !self.viewModel.purchase(product: product) {
                self.showSingleAlert(withMessage: "In-App Purchases are not allowed in this device.")
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK: - ViewModelDelegate
extension ViewController: ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool) {
        overlayView.isHidden = !shouldShow
    }
    
    func willStartLongProcess() {
        overlayView.isHidden = false
    }
    
    func didFinishLongProcess() {
        overlayView.isHidden = true
    }
    
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        
        // In a real app you might want to check what exactly the
        // error is and display a more user-friendly message.
        // For example:
        /*
        switch error {
        case .noProductIDsFound: message = NSLocalizedString("Unable to initiate in-app purchases.", comment: "")
        case .noProductsFound: message = NSLocalizedString("Nothing was found to buy.", comment: "")
        // Add more cases...
        default: message = ""
        }
        */
        
        showSingleAlert(withMessage: message)
    }
    
    
    func shouldUpdateUI() {
        tableView.reloadData()
    }
    
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.")
    }
    
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!")
    }
}




// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.didUnlockAllMaps ? 2 : 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dequeuedCell: CustomCell?
        
        if indexPath.row == 0 || indexPath.row == 1 {
            dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "consumablesCell", for: indexPath) as? CustomCell
        } else {
            dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "nonConsumablesCell", for: indexPath) as? CustomCell
        }
        
        guard let cell = dequeuedCell else { return UITableViewCell() }
        cell.backgroundColor = .clear
        if indexPath.row == 0 {
            cell.itemImageView.image = UIImage(named: "heart")
            cell.topSeparator.isHidden = true
            
            if viewModel.availableExtraLives == 0 {
                cell.titleLabel.text = "No extra lives!\nBuy now!"
                cell.remainingLabel.isHidden = true
                cell.lockedImageView.isHidden = false
            } else {
                cell.titleLabel.text = "Remaining Lives"
                cell.remainingLabel.isHidden = false
                cell.remainingLabel.text = "\(viewModel.availableExtraLives)"
                cell.lockedImageView.isHidden = true
            }
        } else if indexPath.row == 1 {
            cell.itemImageView.image = UIImage(named: "superhero")
            
            if viewModel.availableSuperPowers == 0 {
                cell.titleLabel.text = "No super powers!\nBuy now!"
                cell.remainingLabel.isHidden = true
                cell.lockedImageView.isHidden = false
            } else {
                cell.titleLabel.text = "Remaining super powers"
                cell.remainingLabel.isHidden = false
                cell.remainingLabel.text = "\(viewModel.availableSuperPowers)"
                cell.lockedImageView.isHidden = true
            }
        } else {
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 2 {
            return 120.0
        } else {
            return 150.0
        }
    }
}


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 && viewModel.availableExtraLives == 0 || indexPath.row == 1 && viewModel.availableSuperPowers == 0 || indexPath.row == 2 {
            guard let product = viewModel.getProductForItem(at: indexPath.row) else {
                showSingleAlert(withMessage: "Renewing this item is not possible at the moment.")
                return
            }
            
            showAlert(for: product)
        
        } else {
            
            if indexPath.row == 0 {
                viewModel.didConsumeLive()
            } else {
                viewModel.didConsumeSuperPower()
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
}
