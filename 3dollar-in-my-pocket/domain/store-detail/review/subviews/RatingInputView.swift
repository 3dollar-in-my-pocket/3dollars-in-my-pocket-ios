import UIKit

import RxSwift
import RxCocoa

final class RatingInputView: BaseView {
    fileprivate let ratingPublisher = PublishSubject<Int>()
    
    private let star1 = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
        $0.showsTouchWhenHighlighted = false
    }
    
    private let star2 = UIButton().then {
        $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
    }
    
    private let star3 = UIButton().then {
        $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
    }
    
    private let star4 = UIButton().then {
        $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
    }
    
    private let star5 = UIButton().then {
        $0.setImage(UIImage(named: "ic_star_32_on"), for: .selected)
        $0.setImage(UIImage(named: "ic_star_32_off"), for: .normal)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.backgroundColor = .clear
        $0.spacing = 8
    }
    
    private let stackContainer = UIView().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor(r: 223, g: 223, b: 223).cgColor
        $0.layer.borderWidth = 1
    }
    
    override func setup() {
        self.addSubViews([
            self.stackContainer,
            self.stackView
        ])
        self.stackView.addArrangedSubview(star1)
        self.stackView.addArrangedSubview(star2)
        self.stackView.addArrangedSubview(star3)
        self.stackView.addArrangedSubview(star4)
        self.stackView.addArrangedSubview(star5)
        
        self.star1.rx.tap
            .map { 1 }
            .do(onNext: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .bind(to: self.ratingPublisher)
            .disposed(by: self.disposeBag)
        
        self.star2.rx.tap
            .map { 2 }
            .do(onNext: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .bind(to: self.ratingPublisher)
            .disposed(by: self.disposeBag)
        
        self.star3.rx.tap
            .map { 3 }
            .do(onNext: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .bind(to: self.ratingPublisher)
            .disposed(by: self.disposeBag)
        
        self.star4.rx.tap
            .map { 4 }
            .do(onNext: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .bind(to: self.ratingPublisher)
            .disposed(by: self.disposeBag)
        
        self.star5.rx.tap
            .map { 5 }
            .do(onNext: { [weak self] rating in
                self?.onTapStackView(tappedIndex: rating)
            })
            .bind(to: self.ratingPublisher)
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.stackContainer.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        
        self.star1.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        self.star2.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        self.star3.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        self.star4.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        self.star5.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        self.stackView.snp.makeConstraints { (make) in
            make.centerY.equalTo(stackContainer)
            make.left.equalTo(stackContainer).offset(14)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.stackContainer).priority(.high)
            make.bottom.equalTo(self.stackContainer).priority(.high)
        }
    }
    
    func onTapStackView(tappedIndex: Int) {
        self.stackContainer.layer.borderColor = tappedIndex == 0
        ? UIColor(r: 223, g: 223, b: 223).cgColor
        : UIColor(r: 243, g: 162, b: 169).cgColor
        for index in self.stackView.arrangedSubviews.indices {
            if let button = stackView.arrangedSubviews[index] as? UIButton {
                button.isSelected = (index <= tappedIndex - 1)
            }
        }
    }
}

extension Reactive where Base: RatingInputView {
    var rating: ControlEvent<Int> {
        return ControlEvent(events: base.ratingPublisher)
    }
}
