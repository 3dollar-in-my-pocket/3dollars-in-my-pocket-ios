import UIKit
import Combine

import Common
import DesignSystem

final class RatingInputView: BaseView {
    enum Layout {
        static let size = CGSize(width: 176, height: 32)
    }
    
    let ratingPublisher = PassthroughSubject<Int, Never>()
    
    private let star1: UIButton = {
        let button = UIButton()
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: .normal)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: [.normal, .highlighted])
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: .selected)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: [.selected, .highlighted])
        button.showsTouchWhenHighlighted = false
        
        return button
    }()
    
    private let star2: UIButton = {
        let button = UIButton()
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: .normal)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: [.normal, .highlighted])
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: .selected)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: [.selected, .highlighted])
        button.showsTouchWhenHighlighted = false
        
        return button
    }()
    
    private let star3: UIButton = {
        let button = UIButton()
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: .normal)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: [.normal, .highlighted])
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: .selected)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: [.selected, .highlighted])
        button.showsTouchWhenHighlighted = false
        
        return button
    }()
    
    private let star4: UIButton = {
        let button = UIButton()
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: .normal)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: [.normal, .highlighted])
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: .selected)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: [.selected, .highlighted])
        button.showsTouchWhenHighlighted = false
        
        return button
    }()
    
    private let star5: UIButton = {
        let button = UIButton()
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: .normal)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.gray20.color), for: [.normal, .highlighted])
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: .selected)
        button.setImage(Icons.starSolid.image.withTintColor(Colors.mainPink.color), for: [.selected, .highlighted])
        button.showsTouchWhenHighlighted = false
        
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
        stackView.spacing = 4
        
        return stackView
    }()
    
    override func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(star1)
        stackView.addArrangedSubview(star2)
        stackView.addArrangedSubview(star3)
        stackView.addArrangedSubview(star4)
        stackView.addArrangedSubview(star5)
        
        star1.controlPublisher(for: .touchUpInside)
            .map { _ in 1 }
            .handleEvents(receiveOutput: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .subscribe(ratingPublisher)
            .store(in: &cancellables)
        
        star2.controlPublisher(for: .touchUpInside)
            .map { _ in 2 }
            .handleEvents(receiveOutput: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .subscribe(ratingPublisher)
            .store(in: &cancellables)
        
        star3.controlPublisher(for: .touchUpInside)
            .map { _ in 3 }
            .handleEvents(receiveOutput: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .subscribe(ratingPublisher)
            .store(in: &cancellables)
        
        star4.controlPublisher(for: .touchUpInside)
            .map { _ in 4 }
            .handleEvents(receiveOutput: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .subscribe(ratingPublisher)
            .store(in: &cancellables)
        
        star5.controlPublisher(for: .touchUpInside)
            .map { _ in 5 }
            .handleEvents(receiveOutput: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .subscribe(ratingPublisher)
            .store(in: &cancellables)
    }
    
    override func bindConstraints() {
        star1.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        star2.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        star3.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        star4.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        star5.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        stackView.snp.makeConstraints {
            $0.size.equalTo(Layout.size)
            $0.edges.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(stackView).priority(.high)
        }
    }
    
    func onTapStackView(tappedIndex: Int) {
        clearButtons()
        for index in stackView.arrangedSubviews.indices {
            if let button = stackView.arrangedSubviews[index] as? UIButton {
                button.isSelected = (index <= tappedIndex - 1)
            }
        }
    }
    
    private func clearButtons() {
        star1.isSelected = false
        star2.isSelected = false
        star3.isSelected = false
        star4.isSelected = false
        star5.isSelected = false
    }
}
