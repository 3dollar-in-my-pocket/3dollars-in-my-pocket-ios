import RxSwift

struct WriteDetailViewModel {
    var btnEnable = BehaviorSubject<Void>.init(value: ())
    var menuList: [Menu] = []
    var imageList: [UIImage] = []
}
