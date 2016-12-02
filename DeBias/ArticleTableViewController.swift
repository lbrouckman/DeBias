//
//  ArticleTableViewController.swift
//  DeBias
//
//  Created by Elizabeth Brouckman on 11/29/16.
//  Copyright © 2016 debias. All rights reserved.
//

import UIKit
import CoreData

class ArticleTableViewController: CoreDataTableViewController {
    
    var typeOfArticle: String?
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            updateUI()
        }
    }
    
    var urls = [String]()
    
    private func updateUI() {
        if typeOfArticle?.characters.count > 0
        {
            let articles = UserDefaults.getArticleList(typeOfArticle!)!
            
            //Set size of urls array
            for _ in articles
            {
                urls.append("")
            }
            
            if let context = managedObjectContext {
                let request = NSFetchRequest(entityName: "Article")
                request.predicate = NSPredicate(format: "title in %@", articles)
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
                fetchedResultsController = NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: context,
                    sectionNameKeyPath: nil,
                    cacheName: nil
                )
            } else {
                fetchedResultsController = nil
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleCell", forIndexPath: indexPath) as! ArticleTableViewCell
        
        if let article = fetchedResultsController?.objectAtIndexPath(indexPath) as? Article {
            var title: String?
            var author: String?
            var source: String?
            var type: String?
            var typeExplanation: String?
            var url: String?
            article.managedObjectContext?.performBlockAndWait {
                title = article.title
                author = article.author
                source = article.source
                type = article.type
                typeExplanation = article.typeExplanation
                url = article.url
            }
            cell.titleLabel?.text = title
            cell.authorLabel?.text = author
            cell.url = url
            cell.type = type
            cell.typeExplanation = typeExplanation
            cell.sourceLabel?.text = source
            urls[indexPath.row] = url!
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "openWebview"{
                if let cell = sender as? ArticleTableViewCell, let indexPath = tableView.indexPathForCell(cell),
                    let webvc = segue.destinationViewController as? WebViewController {
                    webvc.url = urls[indexPath.row]
                }
            }
        }
        
    }
    
}