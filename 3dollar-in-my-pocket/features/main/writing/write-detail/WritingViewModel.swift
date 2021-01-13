import RxSwift

struct WritingViewModel {
    var btnEnable = BehaviorSubject<Void>.init(value: ())
    var menuList: [Menu] = []
    var imageList: [UIImage] = []
}
