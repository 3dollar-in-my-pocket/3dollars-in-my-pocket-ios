import RxSwift

class FAQVC: BaseVC {
  
  private lazy var faqView = FAQView(frame: self.view.frame)
  private let viewModel = FAQViewModel(faqService: FAQService())
  
  
  static func instance() -> FAQVC {
    return FAQVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = faqView
    self.initilizeTagCollectionView()
    self.initilizeFAQTableView()
    self.viewModel.fetchFAQs()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.faqTags
      .bind(to: self.faqView.tagCollectionView.rx.items(
              cellIdentifier: FAQTagCell.registerId,
              cellType: FAQTagCell.self
      )) { row, tag, cell in
        cell.bind(name: tag.name)
      }
      .disposed(by: disposeBag)
    
    self.viewModel.output.refreshTableView
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.faqView.faqTableView.reloadData)
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectTag
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.selectTag(row:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.faqView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func initilizeTagCollectionView() {
    self.faqView.tagCollectionView.register(
      FAQTagCell.self,
      forCellWithReuseIdentifier: FAQTagCell.registerId
    )
    self.faqView.tagCollectionView.rx.setDelegate(self)
      .disposed(by: disposeBag)
  }
  
  private func initilizeFAQTableView() {
    self.faqView.faqTableView.register(
      FAQCell.self,
      forCellReuseIdentifier: FAQCell.registerId
    )
    self.faqView.faqTableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    self.faqView.faqTableView.rx
      .setDataSource(self)
      .disposed(by: disposeBag)
  }
  
  private func selectTag(row: Int) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      let indexPath = IndexPath(row: row, section: 0)
      self.faqView.tagCollectionView.selectItem(
        at: indexPath,
        animated: true,
        scrollPosition: .centeredVertically
      )
      self.collectionView(self.faqView.tagCollectionView, didSelectItemAt: indexPath)
    }
  }
}

extension FAQVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? FAQTagCell else { return }
    self.viewModel.input.tapCategory.onNext(indexPath.row)
    cell.setSelect(isSelected: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? FAQTagCell else { return }
    cell.setSelect(isSelected: false)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    //Where elements_count is the count of all your items in that
    //Collection view...
    let cellCount = CGFloat(6)
    
    //If the cell count is zero, there is no point in calculating anything.
    if cellCount > 0 {
      let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
      let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
      
      //20.00 was just extra spacing I wanted to add to my cell.
      let totalCellWidth = cellWidth*cellCount + 20.00 * (cellCount-1)
      let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
      
      if (totalCellWidth < contentWidth) {
        //If the number of cells that exists take up less room than the
        //collection view width... then there is an actual point to centering them.
        
        //Calculate the right amount of padding to center the cells.
        let padding = (contentWidth - totalCellWidth) / 4.0
        return UIEdgeInsets(top: 0, left: padding / 2, bottom: 0, right: padding / 2)
      } else {
        //Pretty much if the number of cells that exist take up
        //more room than the actual collectionView width, there is no
        // point in trying to center them. So we leave the default behavior.
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
      }
    }
    return UIEdgeInsets.zero
  }
}

extension FAQVC: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.viewModel.filteredfaqs.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.filteredfaqs[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: FAQCell.registerId, for: indexPath) as? FAQCell else {
      return BaseTableViewCell()
    }
    let faq = self.viewModel.filteredfaqs[indexPath.section][indexPath.row]
    
    cell.bind(faq: faq)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = FAQHeaderView(frame: CGRect(
                                    x: 0,
                                    y: 0,
                                    width: tableView.frame.size.width,
                                    height: 40
    ))
    
    let tagName = self.viewModel.filteredfaqs[section][0].tags[0].name
    
    headerView.bind(title: tagName)
    return headerView
  }
}
