//
//  AppleProductsTableViewController.swift
//  Pretty Apple
//
//  Created by Duc Tran on 3/28/15.
//  Copyright (c) 2015 Duc Tran. All rights reserved.
//

import UIKit
import Social

class AppleProductsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        
        // Make the row height dynamic
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    

    // MARK: - Data Source
    
    lazy var productLines: [ProductLine] = {
        return ProductLine.productLines()
    }()
    
    var productShown = [Bool](count: ProductLine.numberOfProducts, repeatedValue: false)
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let productLine = productLines[section]
        return productLine.name
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return productLines.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productLine = productLines[section]
        return productLine.products.count   // the number of products in the section
    }

    // indexPath: which section and which row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Product Cell", forIndexPath: indexPath) as! ProductTableViewCell

        let productLine = productLines[indexPath.section]
        let product = productLine.products[indexPath.row]
        
        cell.configureCellWith(product)
        
        return cell
    }
    
    // MARK: - Edit Tableview
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let productLine = productLines[indexPath.section]
            productLine.products.removeAtIndex(indexPath.row)
            // tell the table view to update with new data source
//            tableView.reloadData()    Bad way!
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // MARK: - Animate Table View Cell
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // first
        
        if productShown[indexPath.row] == false {
            
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                
                cell.layer.transform = CATransform3DIdentity
                
            })
            
            productShown[indexPath.row] = true
            
        }
    }
      
    
    // performSegueWithIdentifier(identifier: "", sender: AnyObject?)
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
                case "Show Detail":
                    let productDetailVC = segue.destinationViewController as! ProductDetailViewController
                    if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                        productDetailVC.product = productAtIndexPath(indexPath)
                    }
                case "Show Edit":
                    let editTableVC = segue.destinationViewController as! EditTableViewController
                    if let indexPath = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                        editTableVC.product = productAtIndexPath(indexPath)
                    }
                
                default: break
            }
        }
    }
    
    // MARK: - Table View Cell Action
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        let product = productLines[indexPath.section].products[indexPath.row]
        let productTitle = product.title
        let initialText = "\(productTitle) -- "
        let image = product.image
        
        var shareAction = UITableViewRowAction(style: .Default, title: "Share") { (action, indexPath) -> Void in
            
            let shareActionsheet = UIAlertController(title: "Share with", message: nil, preferredStyle: .ActionSheet)
            
            let twitterAction = UIAlertAction(title: "Twitter", style: .Default) { (action) in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                    let tweetComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    tweetComposer.setInitialText(initialText)
                    tweetComposer.addImage(image)
                    
                    self.presentViewController(tweetComposer, animated: true, completion: nil)
                } else {
                    self.alert("Twitter Unavailable", message: "Please set up your Twitter in Settings to share this with your friends")
                }
            }
            
            let facebookAction = UIAlertAction(title: "Facebook", style: .Default) { (action) in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                    let facebookComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    facebookComposer.setInitialText(initialText)
                    facebookComposer.addImage(image)
                    
                    self.presentViewController(facebookComposer, animated: true, completion: nil)
                } else {
                    self.alert("Facebook Unavailable", message: "Please set up your Facebook in Settings to share this with your friends")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            shareActionsheet.addAction(twitterAction)
            shareActionsheet.addAction(facebookAction)
            shareActionsheet.addAction(cancelAction)
            
            self.presentViewController(shareActionsheet, animated: true, completion: nil)
        }
        
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
            let productLine = self.productLines[indexPath.section]
            productLine.products.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        
        shareAction.backgroundColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction]
    }
    
    func alert(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Method
    
    func productAtIndexPath(indexPath: NSIndexPath) -> Product
    {
        let productLine = productLines[indexPath.section]
        return productLine.products[indexPath.row]
    }
    
}







































