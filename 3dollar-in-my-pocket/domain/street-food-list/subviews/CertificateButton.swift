import UIKit

import RxSwift
import RxCocoa

final class CertificateButton: UIButton {
    private let disposeBag = DisposeBag()
    fileprivate let isCertificatedPublisher = PublishSubject<Bool>()
    
    private let checkImage = UIImageView().then {
        $0.image = UIImage(named: "ic_check_off")
    }
    
    private let subjectLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = Color.pink
        $0.text = "category_list_certificated".localized
    }
    
    override var isSelected: Bool {
        didSet {
            self.checkImage.image = self.isSelected
            ? UIImage(named: "ic_check_on")
            : UIImage(named: "ic_check_off")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = UIColor(r: 255, g: 161, b: 170, a: 0.1)
        self.layer.cornerRadius = 12
        self.accessibilityLabel = "category_list_certificated".localized
        self.addSubViews([
            self.subjectLabel,
            self.checkImage
        ])
        
        self.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.isSelected.toggle()
                self.isCertificatedPublisher.onNext(self.isSelected)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindConstraints() {
        self.checkImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(16)
        }
        
        self.subjectLabel.snp.makeConstraints { make in
            make.left.equalTo(self.checkImage.snp.right).offset(8)
            make.centerY.equalTo(self.checkImage)
        }
        
        self.snp.makeConstraints { make in
            make.left.equalTo(self.checkImage).offset(-14).priority(.high)
            make.top.equalTo(self.checkImage).offset(-14).priority(.high)
            make.bottom.equalTo(self.checkImage).offset(14).priority(.high)
            make.right.equalTo(self.subjectLabel).offset(14).priority(.high)
        }
    }
}

extension Reactive where Base: CertificateButton {
    var isCertificated: ControlEvent<Bool> {
        return ControlEvent(events: base.isCertificatedPublisher)
    }
}
