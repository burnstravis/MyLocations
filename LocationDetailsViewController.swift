//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Travis Burns on 2/10/24.
//

import UIKit
import CoreData
import CoreLocation

//date format object
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {
    
    //coordinates
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = Date()
    
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(
                    location.latitude,
                    location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    
    var image: UIImage?
    
    var observer: Any!
    
    //outlets
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var addPhotoLabel: UILabel!
    @IBOutlet var imageHeight: NSLayoutConstraint!

    //done button
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }
        
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        //Save image
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        //Save data
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            fatalCoreDataError(error)
        }
        
    }

    
    //cancel button
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    //category selected return to previous screen
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
      }
    
    //hide keyboard function on click outside box
    @objc func hideKeyboard(
      _ gestureRecognizer: UIGestureRecognizer
    ){
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    if indexPath != nil && indexPath!.section == 0 &&
        indexPath!.row == 0 {
        return
      }
      descriptionTextView.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto {
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        let gestureRecognizer = UITapGestureRecognizer(
        target: self,action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
    }
    
    //format string
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ",")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }
    
    //formats date into a string
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    //sets selectedCategoryName property
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as!
            CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    //limits taps to cells in first 2 sections
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    //responds to row being tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
          }
    }
    
    //resize imagine after adding photo to fit image view
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        imageHeight.constant = 260
        tableView.reloadData()
    }
    
    //returns to previous screen before an action if app closed
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
                if let weakSelf = self {
                    if weakSelf.presentedViewController != nil {
                        weakSelf.dismiss(animated: false, completion: nil)
                    }
                    weakSelf.descriptionTextView.resignFirstResponder()
                }
        }
    }
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer!)
    }
    
}


extension LocationDetailsViewController:
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    //take photo
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    //finsihed taking photo
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info:
      [UIImagePickerController.InfoKey: Any] ){
          image = info[UIImagePickerController.InfoKey.editedImage] as?
          UIImage
          if let theImage = image {
              show(image: theImage)
          }
          dismiss(animated: true, completion: nil)
      }
    
    //canceled taking photo
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    //choose photo from library
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    //chose from library or camera
    func showPhotoMenu() {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(
          title: "Take Photo",
          style: .default) { _ in
            self.takePhotoWithCamera()
          }
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(
          title: "Choose From Library",
          style: .default) { _ in
            self.choosePhotoFromLibrary()
          }
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
        
    }
    
}
