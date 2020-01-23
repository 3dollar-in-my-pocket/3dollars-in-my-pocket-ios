import UIKit

protocol DeleteModalViewDelegate: class {
    func onTapRequest()
    
    func onTapClose()
}

class DeleteModalView: BaseView {
    
    weak var delegate: DeleteModalViewDelegate?
    var deleteReason = ""
    
    let containerView = UIView().then {
        $0.layer.cornerRadius = 40
        $0.backgroundColor = .white
    }
    
    let titleLabel = UILabel().then {
        $0.text = "삭제하시는\n이유가 궁금해요!"
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 28)
        $0.textColor = .black
        $0.numberOfLines = 0
    }
    
    let closeBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_close_24"), for: .normal)
        $0.addTarget(self, action: #selector(onTapClose), for: .touchUpInside)
    }
    
    let descLabel = UILabel().then {
        $0.text = "5건 이상의 삭제요청이 들어오면 자동 삭제됩니다"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 12)
        $0.textColor = UIColor.init(r: 189, g: 189, b: 189)
    }
    
    let removedBtn = UIButton().then {
        $0.setTitle("     없어진 가게에요", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setTitleColor(UIColor.init(r: 28, g: 28, b: 28), for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(onTapRemoveBtn), for: .touchUpInside)
    }
    
    let removedCheck = UIImageView().then {
        $0.image = UIImage.init(named: "ic_check")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    let locationBtn = UIButton().then {
        $0.setTitle("     위치가 잘못됐어요", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setTitleColor(UIColor.init(r: 28, g: 28, b: 28), for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(onTapLocationBtn), for: .touchUpInside)
    }
    
    let locationCheck = UIImageView().then {
        $0.image = UIImage.init(named: "ic_check")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    let overlapBtn = UIButton().then {
        $0.setTitle("     중복 제보된 가게에요", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setTitleColor(UIColor.init(r: 28, g: 28, b: 28), for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(onTapOverlap), for: .touchUpInside)
    }
    
    let overlapCheck = UIImageView().then {
        $0.image = UIImage.init(named: "ic_check")
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    let deleteBtn = UIButton().then {
        $0.setTitle("삭제 요청", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setBackgroundColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
        $0.setBackgroundColor(UIColor.init(r: 200, g: 200, b: 200), for: .disabled)
        $0.isEnabled = false
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(onTapRequest), for: .touchUpInside)
    }
    
    
    override func setup() {
        addSubViews(containerView, deleteBtn, titleLabel, closeBtn, descLabel,
                    removedBtn, removedCheck, locationBtn, locationCheck,
                    overlapBtn, overlapCheck, deleteBtn)
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-48)
        }
        
        deleteBtn.snp.makeConstraints { (make) in
            make.left.equalTo(containerView).offset(25)
            make.right.equalTo(containerView).offset(-24)
            make.bottom.equalTo(containerView).offset(-24)
            make.height.equalTo(48)
        }
        
        overlapBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(deleteBtn)
            make.bottom.equalTo(deleteBtn.snp.top).offset(-24)
            make.height.equalTo(40)
        }
        
        overlapCheck.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerY.equalTo(overlapBtn)
            make.right.equalTo(overlapBtn).offset(-16)
        }
        
        locationBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(deleteBtn)
            make.bottom.equalTo(overlapBtn.snp.top).offset(-8)
            make.height.equalTo(40)
        }
        
        locationCheck.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerY.equalTo(locationBtn)
            make.right.equalTo(locationBtn).offset(-16)
        }
        
        removedBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(deleteBtn)
            make.bottom.equalTo(locationBtn.snp.top).offset(-8)
            make.height.equalTo(40)
        }
        
        removedCheck.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.centerY.equalTo(removedBtn)
            make.right.equalTo(removedBtn).offset(-16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(deleteBtn)
            make.bottom.equalTo(removedBtn.snp.top).offset(-24)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel)
            make.right.equalTo(deleteBtn)
            make.width.height.equalTo(24)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.top).offset(-24)
        }
    }
    
    @objc func onTapClose() {
        delegate?.onTapClose()
    }
    
    @objc func onTapRequest() {
        delegate?.onTapRequest()
    }
    
    @objc func onTapRemoveBtn() {
        deleteBtn.isEnabled = true
        deleteReason = "NOSTORE"
        selectBtn(index: 0)
    }
    
    @objc func onTapLocationBtn() {
        deleteBtn.isEnabled = true
        deleteReason = "WRONGNOPOSITION"
        selectBtn(index: 1)
    }
    
    @objc func onTapOverlap() {
        deleteBtn.isEnabled = true
        deleteReason = "OVERLAPSTORE"
        selectBtn(index: 2)
    }
    
    func selectBtn(index: Int) {
        switch index {
        case 0:
            removedCheck.isHidden = false
            removedBtn.layer.borderColor = UIColor.init(r: 238, g: 98, b: 76).cgColor
            locationCheck.isHidden = true
            locationBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
            overlapCheck.isHidden = true
            overlapBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        case 1:
            removedCheck.isHidden = true
            removedBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
            locationCheck.isHidden = false
            locationBtn.layer.borderColor = UIColor.init(r: 238, g: 98, b: 76).cgColor
            overlapCheck.isHidden = true
            overlapBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
        case 2:
            removedCheck.isHidden = true
            removedBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
            locationCheck.isHidden = true
            locationBtn.layer.borderColor = UIColor.init(r: 228, g: 228, b: 228).cgColor
            overlapCheck.isHidden = false
            overlapBtn.layer.borderColor = UIColor.init(r: 238, g: 98, b: 76).cgColor
        default:
            break
        }
    }
}
