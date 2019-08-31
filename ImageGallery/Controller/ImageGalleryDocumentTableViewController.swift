//
//  ImageGalleryDocumentTableViewController.swift
//  ImageGallery
//
//  Created by Abdalla Elsaman on 8/30/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import UIKit

class ImageGalleryDocumentTableViewController: UITableViewController {
    

    var Documents = [[ImageGallery(name: "Gallery1"), ImageGallery(name: "Gallery2")], []]
    
    override func viewDidLoad() {
        navigationItem.title = "Documents"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Documents.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = (section == 0) ? "Working Documents": "Recently Deleted"
        label.backgroundColor = .lightGray
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Documents[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)

        cell.textLabel?.text = Documents[indexPath.section][indexPath.row].name
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        tap.numberOfTapsRequired = 2
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    @objc
    private func buttonTapped() {
        print("tapped")
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let undelete = UIContextualAction(style: .normal, title: "Undelete") { [unowned self] (action, view, success: (Bool) -> Void) in
                success(true)
                let unDeletedRow = self.Documents[indexPath.section][indexPath.row]
                self.Documents[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.Documents[0].append(unDeletedRow)
                tableView.reloadSections(IndexSet(integersIn: 0...0), with: .automatic)
            }
            undelete.backgroundColor = .lightGray
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let DeletedRow = Documents[indexPath.section][indexPath.row]
            Documents[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            //
            if indexPath.section == 0 {
                Documents[1].append(DeletedRow)
                tableView.reloadSections(IndexSet(integersIn: 1...1), with: .top)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "ShowImageCollection", sender: indexPath)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailCVC = segue.destination.contents as? ImageGalleryCollectionViewController {
            if let indexPath = sender as? IndexPath {
                detailCVC.imageGallary = Documents[indexPath.section][indexPath.row]
            }
        }
    }

}

extension ImageGalleryDocumentTableViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
}
