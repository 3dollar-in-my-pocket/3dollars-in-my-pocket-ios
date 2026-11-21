import UIKit

import Common
import DesignSystem

final class WriteCloseViewController: BaseViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemWhite.color
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteCloseModal.title
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteCloseModal.description
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray70.color
        return label
    }()
    
    private let cancelButton = Button.Normal(size: .medium, style: .outline, text: Strings.WriteCloseModal.cancel)
    
    private let dismissButton = Button.Normal(size: .medium, style: .destructive, text: Strings.WriteCloseModal.dismiss)
    
    private var onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubViews([
            titleLabel,
            descriptionLabel,
            cancelButton,
            dismissButton
        ])
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(172)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
            $0.height.equalTo(28)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.trailing.equalTo(containerView.snp.centerX).offset(-6)
        }
        
        dismissButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.leading.equalTo(containerView.snp.centerX).offset(6)
            $0.top.bottom.equalTo(cancelButton)
        }
    }
    
    private func bind() {
        cancelButton.tapPublisher
            .sink { [weak self] in
                self?.dismiss(onDismiss: nil)
            }
            .store(in: &cancellables)
        
        dismissButton.tapPublisher
            .sink { [weak self] in
                guard let self else { return }
                dismiss(onDismiss: onDismiss)
            }
            .store(in: &cancellables)
    }
    
    private func dismiss(onDismiss: (() -> Void)? = nil) {
        DimManager.shared.hideDim()
        dismiss(animated: true, completion: onDismiss)
    }
}
