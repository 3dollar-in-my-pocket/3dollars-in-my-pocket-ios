import UIKit


class WritingVC: BaseVC {
    
    private lazy var writingView = WritingView(frame: self.view.frame)
    private let imagePicker = UIImagePickerController()
    private var imageList: [UIImage] = []
    private var selectedImageIndex = 0
    private var menuList: [String] = []
    
    
    static func instance() -> WritingVC {
        let controller = WritingVC(nibName: nil, bundle: nil)
        controller.modalPresentationStyle = .fullScreen
        
        return controller
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = writingView
        imagePicker.delegate = self
        writingView.imageCollection.dataSource = self
        writingView.imageCollection.delegate = self
        writingView.imageCollection.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.registerId)
        
        writingView.menuTableView.delegate = self
        writingView.menuTableView.dataSource = self
        writingView.menuTableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.registerId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onShowKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onHideKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func bindViewModel() {
        writingView.backBtn.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        writingView.bungeoppangBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 0)
        }.disposed(by: disposeBag)
        
        writingView.takoyakiBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 1)
        }.disposed(by: disposeBag)
        
        writingView.gyeranppangBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 2)
        }.disposed(by: disposeBag)
        
        writingView.hotteokBtn.rx.tap.bind { [weak self] in
            self?.writingView.tapCategoryBtn(index: 3)
        }.disposed(by: disposeBag)
        
        writingView.nameField.rx.text.bind { [weak self] (inputText) in
            self?.writingView.setFieldEmptyMode(isEmpty: inputText!.isEmpty)
        }.disposed(by: disposeBag)
        
        // 이거 걸어버리면 사진등록 cell 터치가 안먹음.. ㅠ
//        writingView.bgTap.rx.event.bind { (recognizer) in
//            self.writingView.endEditing(true)
//        }.disposed(by: disposeBag)
    }
    
    @objc func onShowKeyboard(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.writingView.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 50
        self.writingView.scrollView.contentInset = contentInset
    }
    
    @objc func onHideKeyboard(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        
        self.writingView.scrollView.contentInset = contentInset
    }
}

extension WritingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.registerId, for: indexPath) as? ImageCell else {
            return BaseCollectionViewCell()
        }
        
        if indexPath.row < self.imageList.count {
            cell.setImage(image: self.imageList[indexPath.row])
        } else {
            cell.setImage(image: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 104, height: 104)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        AlertUtils.showImagePicker(controller: self, picker: self.imagePicker)
    }
}

extension WritingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if selectedImageIndex == self.imageList.count {
                self.imageList.append(image)
            } else {
                self.imageList[selectedImageIndex] = image
            }
        }
        self.writingView.imageCollection.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension WritingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.registerId, for: indexPath) as? MenuCell else {
            return BaseTableViewCell()
        }
        
        cell.nameField.rx.controlEvent(.editingDidEnd).bind { [weak self] in
            if let inputText = cell.nameField.text {
                if !inputText.isEmpty {
                    if indexPath.row == self?.menuList.count {
                        self?.menuList.append(inputText)
                        self?.writingView.menuTableView.reloadData()
                        self?.view.layoutIfNeeded()
                    } else {
                        self?.menuList[indexPath.row]=(inputText)
                    }
                }
            }
        }.disposed(by: disposeBag)
        return cell
    }
}
