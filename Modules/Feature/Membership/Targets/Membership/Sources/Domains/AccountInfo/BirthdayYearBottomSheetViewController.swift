import UIKit

import Common

import PanModal
import CombineCocoa

final class BirthdayYearBottomSheetViewController: BaseViewController  {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "태어난 년도를 선택해주세요!"
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.systemWhite.color
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icClose.image, for: .normal)
        return button
    }()
    
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.Common.ok, for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainRed.color
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let viewModel: BirthdayYearBottomSheetViewModel
    
    init(viewModel: BirthdayYearBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.gray90.color
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(26)
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(24)
        }
        
        view.addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(40)
            $0.height.equalTo(208)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(pickerView.snp.bottom).offset(40)
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        // Input
        closeButton.tapPublisher
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        confirmButton.tapPublisher
            .subscribe(viewModel.input.didTapConfirm)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewController, route: BirthdayYearBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectYear
            .main
            .withUnretained(self)
            .sink { (owner: BirthdayYearBottomSheetViewController, index: Int) in
                owner.pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            .store(in: &cancellables)
    }
}

extension BirthdayYearBottomSheetViewController {
    private func handleRoute(_ route: BirthdayYearBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        }
    }
}

extension BirthdayYearBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(414)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(414)
    }
    
    var panModalBackgroundColor: UIColor {
        return Colors.systemBlack.color.withAlphaComponent(0.5)
    }
    
    var cornerRadius: CGFloat {
        return 12
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

extension BirthdayYearBottomSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.output.dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = "\(viewModel.output.dataSource[safe: row] ?? 0)"
        label.textAlignment = .center
        label.font = Fonts.semiBold.font(size: 24)
        label.textColor = Colors.systemWhite.color
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.input.didSelectYear.send(row)
    }
}
