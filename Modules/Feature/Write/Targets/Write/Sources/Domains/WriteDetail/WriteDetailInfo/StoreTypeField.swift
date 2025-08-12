import UIKit
import Combine

import Common
import Model

import CombineCocoa

final class StoreTypeField: BaseView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteDetailInfo.StoreType.title
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let storeTypeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let roadTypeButton = StoreTypeButton(title: Strings.WriteDetailInfo.StoreType.road)
    
    private let storeTypeButton = StoreTypeButton(title: Strings.WriteDetailInfo.StoreType.store)
    
    private let foodTruckTypeButton = StoreTypeButton(title: Strings.WriteDetailInfo.StoreType.foodTruck)
    
    private let convienceTypeButton = StoreTypeButton(title: Strings.WriteDetailInfo.StoreType.convience)
    
    let tapPublisher = PassthroughSubject<UserStoreCreateRequestV3.StoreType, Never>()
    
    override func setup() {
        addSubViews([
            titleLabel,
            storeTypeStack
        ])
        
        storeTypeStack.addArrangedSubview(roadTypeButton)
        storeTypeStack.addArrangedSubview(storeTypeButton)
        storeTypeStack.addArrangedSubview(foodTruckTypeButton)
        storeTypeStack.addArrangedSubview(convienceTypeButton)
        
        let tapRoadType = roadTypeButton.tapPublisher
            .throttleClick()
            .map { _ in UserStoreCreateRequestV3.StoreType.road }
        let tapStoreType = storeTypeButton.tapPublisher
            .throttleClick()
            .map { _ in UserStoreCreateRequestV3.StoreType.store }
        let tapFoodTruckType = foodTruckTypeButton.tapPublisher
            .throttleClick()
            .map { _ in UserStoreCreateRequestV3.StoreType.foodTruck }
        let tapConvienceType = convienceTypeButton.tapPublisher
            .throttleClick()
            .map { _ in UserStoreCreateRequestV3.StoreType.convenienceStore }
        
        Publishers.Merge4(tapRoadType, tapStoreType, tapFoodTruckType, tapConvienceType)
            .sink { [weak self] storeType in
                self?.selectStoreType(storeType)
                self?.tapPublisher.send(storeType)
            }
            .store(in: &cancellables)
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        storeTypeStack.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(36)
        }
    }
    
    func selectStoreType(_ type: UserStoreCreateRequestV3.StoreType) {
        roadTypeButton.isSelected = type == .road
        storeTypeButton.isSelected = type == .store
        foodTruckTypeButton.isSelected = type == .foodTruck
        convienceTypeButton.isSelected = type == .convenienceStore
    }
}

private final class StoreTypeButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        titleLabel?.font = Fonts.semiBold.font(size: 14)
        setTitleColor(Colors.gray40.color, for: .normal)
        setTitleColor(Colors.mainPink.color, for: .selected)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = Colors.gray30.color.cgColor
        layer.borderWidth = 1
        
        snp.makeConstraints {
            $0.height.equalTo(36)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = Colors.mainPink.color.cgColor
            } else {
                layer.borderColor = Colors.gray30.color.cgColor
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
