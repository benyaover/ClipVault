//
//  ViewController.swift
//  ClipVault
//
//  Created by Benya Vahdat on 3/24/25.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var clipboardTableView: UITableView!
    @IBOutlet weak var clipboardCountLabel: UILabel!
    @IBOutlet weak var eraseButton: UIButton!
    
    // MARK: - Data Model
    var clipboardItems: [String] = []
    let availableFonts = UIFont.familyNames.sorted()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do not preload sample data; rely on stored clipboard history.
        setupUI()
        loadClipboardHistory()
        setupRefreshControl()
    }
    
    // MARK: - Setup & Data Loading
    func setupUI() {
        // If adding the font picker later, uncomment these:
        // fontPicker.delegate = self
        // fontPicker.dataSource = self
        
        clipboardTableView.delegate = self
        clipboardTableView.dataSource = self
    }
    
    func loadClipboardHistory() {
        // Load clipboard history from UserDefaults; if none exists, start with an empty array.
        clipboardItems = UserDefaults.standard.stringArray(forKey: "clipboardHistory") ?? []
        updateCountLabel()
        clipboardTableView.reloadData()
    }
    
    func updateCountLabel() {
        clipboardCountLabel.text = "\(clipboardItems.count) items in ClipVault"
    }
    
    // MARK: - Refresh Control Setup
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshClipboard(_:)), for: .valueChanged)
        clipboardTableView.refreshControl = refreshControl
    }
    
    @objc func refreshClipboard(_ sender: UIRefreshControl) {
        checkForNewClipboardItem()
        sender.endRefreshing()
    }
    
    func checkForNewClipboardItem() {
        if let currentPaste = UIPasteboard.general.string, !currentPaste.isEmpty {
            // Add only if it's different from the current top item.
            if clipboardItems.first != currentPaste {
                clipboardItems.insert(currentPaste, at: 0)
                UserDefaults.standard.set(clipboardItems, forKey: "clipboardHistory")
                updateCountLabel()
                clipboardTableView.reloadData()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func eraseClipVault(_ sender: UIButton) {
        clipboardItems.removeAll()
        UserDefaults.standard.set(clipboardItems, forKey: "clipboardHistory")
        updateCountLabel()
        clipboardTableView.reloadData()
    }
    
    // MARK: - Copied Animation
    func showCopiedAnimation() {
        let copiedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        copiedLabel.text = "Copied"
        copiedLabel.textAlignment = .center
        // Using the system font for now.
        copiedLabel.font = UIFont.systemFont(ofSize: 24)
        copiedLabel.center = view.center
        copiedLabel.alpha = 0
        view.addSubview(copiedLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            copiedLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.0, options: [], animations: {
                copiedLabel.alpha = 0
            }) { _ in
                copiedLabel.removeFromSuperview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForNewClipboardItem()
    }
}

// MARK: - UITableView Delegate and Data Source
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    // Return the number of rows based on clipboardItems count.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clipboardItems.count
    }
    
    // Configure the cell for each clipboard item.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure the cell identifier "ClipboardCell" matches the one set in the storyboard.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClipboardCell", for: indexPath)
        cell.textLabel?.text = clipboardItems[indexPath.row]
        return cell
    }
    
    // When a cell is tapped, copy the item, move it to the top, and show the "Copied" animation.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = clipboardItems.remove(at: indexPath.row)
        clipboardItems.insert(item, at: 0)
        UIPasteboard.general.string = item
        UserDefaults.standard.set(clipboardItems, forKey: "clipboardHistory")
        updateCountLabel()
        clipboardTableView.reloadData()
        showCopiedAnimation()
    }
}

// MARK: - UIPickerView Delegate and Data Source (Optional)
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableFonts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableFonts[row]
    }
}
