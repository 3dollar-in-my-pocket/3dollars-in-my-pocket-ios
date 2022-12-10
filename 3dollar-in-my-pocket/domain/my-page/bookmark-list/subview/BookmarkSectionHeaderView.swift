import UIKit

final class BookmarkSectionHeaderView: BaseCollectionReusableView {
    static let registerId = "\(BookmarkSectionHeaderView.self)"
    static let height: CGFloat = 50
    
    private let countLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = R.color.gray20()
        $0.text = "4개의 리스트"
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
    }
    
    let deleteAllButton = UIButton().then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
    }
    
    let finishButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
        $0.backgroundColor = R.color.gray80()
        $0.layer.cornerRadius = 13
        $0.contentEdgeInsets = .init(top: 4, left: 13, bottom: 4, right: 13)
    }
    
    override func setup() {
        self.addSubViews([
            self.countLabel,
            self.deleteButton,
            self.deleteAllButton,
            self.finishButton
        ])
    }
    
    override func bindConstraints() {
        self.countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(28)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.countLabel)
        }
    }
}
