import RxSwift

struct ModifyViewMode {
    var btnEnable = BehaviorSubject<Void>.init(value: ())
    var menuList: [Menu] = []
    var imageList: [UIImage] = []
}
