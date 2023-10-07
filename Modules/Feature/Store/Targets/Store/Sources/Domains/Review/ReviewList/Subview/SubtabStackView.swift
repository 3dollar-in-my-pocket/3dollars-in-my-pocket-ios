import UIKit
import Combine

import Common
import DesignSystem

final class SubtabStackView: UIStackView {
    enum Layout {
        static let indicatorSize = CGSize(width: 40, height: 1)
        static let buttonHeight: CGFloat = 18
    }
    
    let sortTypePublisher = PassthroughSubject<SortType, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let latestButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.latest.title, for: .normal)
        button.setTitleColor(Colors.gray40.color, for: .normal)
        button.setTitleColor(Colors.gray100.color, for: .selected)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.isSelected = true
        return button
    }()
    
    private let highestRatingButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.highestRating.title, for: .normal)
        button.setTitleColor(Colors.gray40.color, for: .normal)
        button.setTitleColor(Colors.gray100.color, for: .selected)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        return button
    }()
    
    private let lowestRatingButton: UIButton = {
        let button = UIButton()
        button.setTitle(SortType.lowestRating.title, for: .normal)
        button.setTitleColor(Colors.gray40.color, for: .normal)
        button.setTitleColor(Colors.gray100.color, for: .selected)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        return button
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray100.color
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
        bindConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .horizontal
        spacing = 12
        alignment = .leading
        
        addArrangedSubview(latestButton)
        addArrangedSubview(highestRatingButton)
        addArrangedSubview(lowestRatingButton)
        addSubview(indicatorView)
        
        latestButton.controlPublisher(for: .touchUpInside)
            .map { _ in SortType.latest }
            .handleEvents(receiveOutput: { [weak self] type in
                self?.selectTab(type)
            })
            .subscribe(sortTypePublisher)
            .store(in: &cancellables)
        
        highestRatingButton.controlPublisher(for: .touchUpInside)
            .map { _ in SortType.highestRating }
            .handleEvents(receiveOutput: { [weak self] type in
                self?.selectTab(type)
            })
            .subscribe(sortTypePublisher)
            .store(in: &cancellables)
        
        lowestRatingButton.controlPublisher(for: .touchUpInside)
            .map { _ in SortType.lowestRating }
            .handleEvents(receiveOutput: { [weak self] type in
                self?.selectTab(type)
            })
            .subscribe(sortTypePublisher)
            .store(in: &cancellables)
    }
    
    private func bindConstraints() {
        indicatorView.snp.makeConstraints {
            $0.size.equalTo(Layout.indicatorSize)
            $0.centerX.equalTo(latestButton)
            $0.top.equalTo(latestButton.snp.bottom).offset(2)
        }
        
        latestButton.snp.makeConstraints {
            $0.height.equalTo(Layout.buttonHeight)
        }
        
        highestRatingButton.snp.makeConstraints {
            $0.height.equalTo(Layout.buttonHeight)
        }
        
        lowestRatingButton.snp.makeConstraints {
            $0.height.equalTo(Layout.buttonHeight)
        }
    }
    
    func selectTab(_ type: SortType) {
        clearSelect()
        
        switch type {
        case .latest:
            latestButton.isSelected = true
            
        case .highestRating:
            highestRatingButton.isSelected = true
            
        case .lowestRating:
            lowestRatingButton.isSelected = true
        }
        moveIndicator(type)
        sortTypePublisher.send(type)
    }
    
    private func clearSelect() {
        latestButton.isSelected = false
        highestRatingButton.isSelected = false
        lowestRatingButton.isSelected = false
    }
    
    private func moveIndicator(_ tybe: SortType) {
        switch tybe {
        case .latest:
            indicatorView.snp.remakeConstraints {
                $0.size.equalTo(Layout.indicatorSize)
                $0.centerX.equalTo(latestButton)
                $0.top.equalTo(latestButton.snp.bottom).offset(2)
            }
            
        case .highestRating:
            indicatorView.snp.remakeConstraints {
                $0.size.equalTo(Layout.indicatorSize)
                $0.centerX.equalTo(highestRatingButton)
                $0.top.equalTo(latestButton.snp.bottom).offset(2)
            }
            
        case .lowestRating:
            indicatorView.snp.remakeConstraints {
                $0.size.equalTo(Layout.indicatorSize)
                $0.centerX.equalTo(lowestRatingButton)
                $0.top.equalTo(latestButton.snp.bottom).offset(2)
            }
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}

extension SubtabStackView {
    enum SortType: String {
        case latest = "LATEST"
        case highestRating = "HIGHEST_RATING"
        case lowestRating = "LOWEST_RATING"
        
        var title: String {
            switch self {
            case .latest:
                return Strings.ReviewList.SortType.latest
                
            case .highestRating:
                return Strings.ReviewList.SortType.highestRating
                
            case .lowestRating:
                return Strings.ReviewList.SortType.lowestRating
            }
        }
    }
}
