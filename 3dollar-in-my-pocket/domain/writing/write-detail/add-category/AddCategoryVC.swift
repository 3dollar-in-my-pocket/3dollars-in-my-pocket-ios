import UIKit

import RxSwift

protocol AddCategoryDelegate: class {
  
  func onDismiss()
  func onSuccess(selectedCategories: [StreetFoodStoreCategory])
}

class AddCategoryVC: BaseVC {
  
  weak var delegate: AddCategoryDelegate?
  
  private lazy var addCategoryView = AddCategoryView(frame: self.view.frame)
  
  private let viewModel: AddCategoryViewModel
  
  
  init(selectedCategory: [StreetFoodStoreCategory?]) {
    self.viewModel = AddCategoryViewModel(selectedCategory: selectedCategory)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(selectedCategory: [StreetFoodStoreCategory?]) -> AddCategoryVC {
    return AddCategoryVC(selectedCategory: selectedCategory).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = addCategoryView
    self.setupCategoryCollectionView()
    self.viewModel.fetchSelectedCategory()
  }
  
  override func bindViewModel() {
    // Bind input
    self.addCategoryView.selectButton.rx.tap
      .bind(to: self.viewModel.input.tapSelectButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.buttonText
      .bind(to: self.addCategoryView.selectButton.rx.title())
      .disposed(by: disposeBag)
    
    self.viewModel.output.buttonEnable
      .bind(to: self.addCategoryView.selectButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    self.viewModel.output.category.bind(to: self.addCategoryView.categoryCollectionView.rx.items(
      cellIdentifier: AddCategoryCell.registerId,
      cellType: AddCategoryCell.self
    )) { row, category, cell in
      cell.bind(category: category.category, isSelected: category.isSelected)
    }.disposed(by: disposeBag)
    
    self.viewModel.output.selectCategories
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.selectCategories(selectedCategories:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.addCategoryView.tapBackground.rx.event
      .bind { [weak self] _ in
        self?.delegate?.onDismiss()
        self?.dismiss()
      }
      .disposed(by: disposeBag)
  }
  
  private func setupCategoryCollectionView() {
    self.addCategoryView.categoryCollectionView.register(
      AddCategoryCell.self,
      forCellWithReuseIdentifier: AddCategoryCell.registerId
    )
    self.addCategoryView.categoryCollectionView.rx.itemSelected
      .bind(to: self.viewModel.input.tapCategory)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func selectCategories(selectedCategories: [StreetFoodStoreCategory]) {
    self.delegate?.onSuccess(selectedCategories: selectedCategories)
    self.dismiss()
  }
}
