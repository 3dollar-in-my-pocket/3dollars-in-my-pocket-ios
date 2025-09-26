import UIKit

import Common
import CombineCocoa
import DesignSystem

final class EditDismissModalViewController: BaseViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = Colors.systemWhite.color
        stackView.layer.cornerRadius = 20
        stackView.layer.masksToBounds = true
        stackView.layoutMargins = .init(top: 24, left: 20, bottom: 20, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "다음에 할까요?"
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.textAlignment = .left
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "수정된 정보가 있어요. 지금까지 입력한 정보가 저장되지 않아요."
        label.textAlignment = .left
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray70.color
        label.lineBreakStrategy = .pushOut
        label.numberOfLines = 2
        return label
    }()
    
    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("닫기", for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setTitleColor(Colors.gray50.color, for: .normal)
        button.layer.borderColor = Colors.gray40.color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("나가기", for: .normal)
        button.titleLabel?.font = Fonts.semiBold.font(size: 14)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.backgroundColor = Colors.mainRed.color
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    var onClose: (() -> Void)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel, previousSpace: 8)
        stackView.addArrangedSubview(horizontalStackView, previousSpace: 24)
        
        horizontalStackView.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        horizontalStackView.addArrangedSubview(cancelButton)
        horizontalStackView.addArrangedSubview(closeButton)
    }
    
    private func bind() {
        cancelButton.tapPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        closeButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                dismiss(animated: true, completion: onClose)
            }
            .store(in: &cancellables)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)

        DimManager.shared.hideDim()
    }
}
