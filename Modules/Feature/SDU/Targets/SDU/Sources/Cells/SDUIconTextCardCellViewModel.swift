import Combine
import Common
import Model

public final class SDUIconTextCardCellViewModel: BaseViewModel {
    public struct Input { }

    public struct Output {
        let data: IconTextCardData
    }

    public struct Config {
        let data: IconTextCardData

        public init(data: IconTextCardData) {
            self.data = data
        }
    }

    public let input = Input()
    public let output: Output

    public init(config: Config) {
        self.output = Output(data: config.data)
        super.init()
    }
}

extension SDUIconTextCardCellViewModel: Hashable {
    public static func == (lhs: SDUIconTextCardCellViewModel, rhs: SDUIconTextCardCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
