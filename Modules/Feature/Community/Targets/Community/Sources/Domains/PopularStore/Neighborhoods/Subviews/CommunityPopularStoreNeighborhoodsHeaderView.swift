import UIKit

import Common
import DesignSystem

final class CommunityPopularStoreNeighborhoodsHeaderView: BaseView {
    enum Layout {
        static let height: CGFloat = 68
    }
    
    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.arrowLeft.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Colors.gray100.color
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.CommunityPopularStoreNeighborhoodsHeader.title
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 20)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.close.image.resizeImage(scaledTo: 16).withTintColor(.white), for: .normal)
        button.backgroundColor = Colors.gray40.color
        button.layer.cornerRadius = 12
        return button
        
    }()
    
    override func setup() {
        leftStackView.addArrangedSubview(backButton)
        leftStackView.addArrangedSubview(titleLabel)
        
        addSubViews([
            leftStackView,
            closeButton
        ])
        
        backButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        leftStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton)
        }
        
        closeButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerY.equalTo(leftStackView)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    func bind(viewModel: CommunityPopularStoreNeighborhoodsHeaderViewModel) {
        backButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapBack)
            .store(in: &cancellables)
        
        closeButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapClose)
            .store(in: &cancellables)
        
        viewModel.output.title
            .main
            .sink { [weak self] title in
                self?.setTitle(title)
            }
            .store(in: &cancellables)
    }
    
    private func setTitle(_ title: String?) {
        if let title {
            leftStackView.insertArrangedSubview(backButton, at: 0)
            titleLabel.text = title
        } else {
            backButton.removeFromSuperview()
            titleLabel.text = Strings.CommunityPopularStoreNeighborhoodsHeader.title
        }
    }
}
