import UIKit

final class MyVisitHistoryImageView: BaseView {
    static let size = CGSize(width: 72, height: 72)
    
    private let imageView = UIImageView().then {
        $0.image = R.image.img_face_success()
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .light(size: 12)
        $0.textColor = .white
    }
    
    override func setup() {
        self.backgroundColor = UIColor(r: 0, g: 198, b: 103).withAlphaComponent(0.1)
        self.layer.cornerRadius = 12
        self.addSubViews([
            self.imageView,
            self.timeLabel
        ])
    }
    
    override func bindConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(32)
        }
        
        self.timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imageView.snp.bottom).offset(6)
        }
        
        self.snp.makeConstraints { make in
            make.size.equalTo(Self.size)
        }
    }
    
    func bind(visitHistory: VisitHistory) {
        switch visitHistory.type {
        case .exists:
            self.backgroundColor = UIColor(r: 0, g: 198, b: 103).withAlphaComponent(0.1)
            self.imageView.image = R.image.img_face_success()
            
        case .notExists:
            self.backgroundColor = UIColor(r: 235, g: 87, b: 87).withAlphaComponent(0.1)
            self.imageView.image = R.image.img_face_fail()
        }
        self.timeLabel.text = DateUtils.toString(
            dateString: visitHistory.createdAt,
            format: "HH:mm:ss"
        )
    }
}
