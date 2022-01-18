//
//  ViewController.swift
//  BookStore
//
//  Created by Yılmaz Karaağaç on 1/15/22.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var bookArray = [TableViewModel]()
    var selectedItemId: UUID?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        addPlusButton()
        getData()
    }
    
    func addPlusButton() {
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newdata"), object: nil)
    }
    
    @objc func addButtonClicked() {
        selectedItemId = nil
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    @objc func getData() {
        clearArray()
        let context = getContext()
        let fetchRequest = getFetchRequest()
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                var counter = 0
                for res in result as! [NSManagedObject] {
                    let bookModel = TableViewModel()
                    if let id = res.value(forKey: "id") as? UUID {
                        bookModel.id = id
                    }
                    
                    if let name = res.value(forKey: "name") as? String {
                        bookModel.name = name
                    }
                    
                    bookModel.index = counter
                    counter += 1
                    self.bookArray.append(bookModel)
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("error in get data")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let name = bookArray.first { $0.index == indexPath.row }?.name
        cell.textLabel?.text = name
        return cell
    }
    
    func clearArray() {
        bookArray.removeAll()
    }
    
    func getContext() -> NSManagedObjectContext {
        //Access to Core Data start
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //Access to Core Data end
        return context
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = getContext()
            let idString = bookArray.first { $0.index == indexPath.row }?.id.uuidString
            let index = bookArray.first { $0.index == indexPath.row }?.index
            
            let fetchRequest = getFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            
            do {
                let result = try context.fetch(fetchRequest)
                if result.count > 0 {
                    for res in result as! [NSManagedObject] {
                        if let id = res.value(forKey: "id") as? UUID {
                            if id.uuidString == idString {
                                context.delete(res)
                                bookArray.remove(at: index!)
                                self.tableView.reloadData()
                                saveChanges(context: context)
                            }
                        }
                    }
                }
                
            } catch {
                print("delete error")
            }
        }
    }
    
    func getFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
    
    func saveChanges(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("success delete")
        } catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedItemId = bookArray.first { $0.index == indexPath.row }?.id
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenItemId = selectedItemId
        }
    }
    
}

