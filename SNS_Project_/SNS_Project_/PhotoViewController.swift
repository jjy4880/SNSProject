import UIKit
import Photos
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class PhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(presentImagePicker))
        imageView.addGestureRecognizer(tapgesture)
    }
    
    
    @objc func presentImagePicker() {
        PHPhotoLibrary.requestAuthorization { [weak self] (authorizationStatus) in
            DispatchQueue.main.async { [weak self] in
                guard authorizationStatus == .authorized else {
                    self?.needPermissionAlert()
                    return
                }
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.allowsEditing = true
                self?.present(imagePickerController, animated: true) {
                    UIApplication.shared.statusBarStyle = .default
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func needPermissionAlert() {
        let alertController = UIAlertController(title: "사진 접근 거절됨",
                                                message: "게시물을 작성하려면 사진이 필요합니다. \n설정에서 접근을 허용할 수 있습니다.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "설정", style: .destructive) { (action) in
            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: Any) {
        guard let userid = Auth.auth().currentUser?.uid,
            let desc = descriptionTextView.text,
            let image = imageView.image else { return }
        
        guard let saveImage = UIImageJPEGRepresentation(image, 0.1)  else { return }
        
        Storage.storage().reference().child("articlePhotos").child(userid).putData(saveImage, metadata: nil) { (data, err) in
            let imageUrl = data?.downloadURL()?.absoluteString ?? "Has not Found"
            AuthService.pushArticleDataToDatabase(uid: userid, imageUrl: imageUrl, description: desc) {
                self.imageView.image = nil
                self.descriptionTextView.text = "게시글 작성"
            }
        }
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            assertionFailure("Failed to pick photo.")
            return
        }
        self.imageView.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
}

