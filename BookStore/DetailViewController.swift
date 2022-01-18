//
//  DetailViewController.swift
//  BookStore
//
//  Created by Yılmaz Karaağaç on 1/15/22.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chosenItemId: UUID?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isHidden = true
        
        if chosenItemId != nil && chosenItemId?.uuidString != "" {
            let context = getContext()
            let fetchRequest = prepareRequest()
            do {
                let result = try context.fetch(fetchRequest)
                if result.count > 0 {
                    setDataToControls(result: result)
                }
            } catch {
                print("error in detail")
            }
        }
        addTapGesture()
        
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        let context = getContext()
        setBookData(context: context)
        saveChanges(context: context)
        goBack()
    }
    
    func addTapGesture() {
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func imageViewTapped() {
        makeAlert()
    }
    
    func makeAlert() {
        let alert = UIAlertController(title: "Media Source", message: "Use Camera Or Library", preferredStyle: UIAlertController.Style.alert)
        let libraryButton = UIAlertAction(title: "Library", style: UIAlertAction.Style.default) { UIAlertAction in
            print("Library Tapped")
            self.selectImage(sourceType: UIImagePickerController.SourceType.photoLibrary)
        }
        let cameraButton = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { UIAlertAction in
            print("Camera Tapped")
            self.selectImage(sourceType: UIImagePickerController.SourceType.camera)
        }
        
        alert.addAction(libraryButton)
        alert.addAction(cameraButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func selectImage(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage //or original image
        saveButton.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func getContext() -> NSManagedObjectContext {
        //Access to Core Data start
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //Access to Core Data end
        return context
    }
    
    func setBookData(context: NSManagedObjectContext) {
        let newBook = NSEntityDescription.insertNewObject(forEntityName: "Book", into: context)
        newBook.setValue(nameTextField.text, forKey: "name")
        newBook.setValue(isbnTextField.text, forKey: "isbn")
        newBook.setValue(authorTextField.text, forKey: "author")
        newBook.setValue(UUID(), forKey: "id")
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        newBook.setValue(imageData, forKey: "image")
    }
    
    func saveChanges(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
    }
    
    func goBack() {
        NotificationCenter.default.post(name: NSNotification.Name("newdata"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func prepareRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
        let idString = chosenItemId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
    
    func setDataToControls(result: [NSFetchRequestResult]) {
        for res in result as! [NSManagedObject] {
            if let name = res.value(forKey: "name") as? String {
                nameTextField.text = name
            }
            
            if let isbn = res.value(forKey: "isbn") as? String {
                isbnTextField.text = isbn
            }
            
            if let author = res.value(forKey: "author") as? String {
                authorTextField.text = author
            }
            
            if let image = res.value(forKey: "image") as? Data {
                let imageData = UIImage(data: image)
                imageView.image = imageData
            }
        }
    }
}
