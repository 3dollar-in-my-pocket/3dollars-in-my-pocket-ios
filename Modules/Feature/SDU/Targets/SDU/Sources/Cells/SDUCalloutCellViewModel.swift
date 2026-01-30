import Combine
import Common
import Model

public final class SDUCalloutCellViewModel: BaseViewModel {
    public struct Input { }

    public struct Output {
        let data: CalloutCard
    }

    public struct Config {
        let data: CalloutCard

        public init(data: CalloutCard) {
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

extension SDUCalloutCellViewModel: Hashable {
    public static func == (lhs: SDUCalloutCellViewModel, rhs: SDUCalloutCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
