import UIKit
import Common
import DesignSystem
import Model
import UIKit
import SnapKit

final class BossStorePostCell: BaseCollectionViewCell {
    enum Layout {
        static func height(viewModel: BossStorePostCellViewModel, width: CGFloat) -> CGFloat {
            let defaultHeight: CGFloat = 460
            
            if viewModel.output.isExpanded.value {
                let height = viewModel.output.content.boundingRect(
                    with: CGSize(
                        width: width - sectionInset.left - sectionInset.right,
                        height: CGFloat.greatestFiniteMagnitude
                    ),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [
                        .font: Fonts.regular.font(size: 14)
                    ],
                    context: nil
                ).height
                
                return 340 + height
            }
            
            return defaultHeight
        }
        
        static let sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        static let contentTextFont = Fonts.regular.font(size: 14)
        static let contentTextColor = Colors.gray95.color
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = "가게 소식"
    }
    
    private let moreButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.setTitle("더보기", for: .normal)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 16
    }
    
    private let categoryImageView = UIImageView()
    
    private let storeNameLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }
    
    private let updatedAtLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 12)
        $0.textColor = Colors.gray40.color
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.dataSource = self
        $0.delegate = self
        $0.decelerationRate = .fast
        $0.register(BossStorePostImageCell.self, forCellWithReuseIdentifier: "BossStorePostImageCell")
    }
    
    private let textView = UITextView().then {
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.textContainer.lineFragmentPadding = 0
        $0.font = Layout.contentTextFont
        $0.backgroundColor = .clear
    }
    
    private let tapGesture = UITapGestureRecognizer()
    
    private weak var viewModel: BossStorePostCellViewModel?
    
    override func setup() {
        backgroundColor = .clear
        textView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(toggleTextView))
        
        contentView.addSubViews([
            titleLabel,
            moreButton,
            containerView
        ])
        
        containerView.addSubViews([
            categoryImageView,
            storeNameLabel,
            updatedAtLabel,
            collectionView,
            textView
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        categoryImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        storeNameLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            $0.top.equalToSuperview().inset(17)
            $0.height.equalTo(20)
        }
        
        updatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom)
            $0.leading.equalTo(storeNameLabel)
            $0.height.equalTo(18)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(208)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 208, height: 208)
        layout.scrollDirection = .horizontal
        layout.sectionInset = Layout.sectionInset
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
    
    func bind(_ viewModel: BossStorePostCellViewModel) {
        self.viewModel = viewModel
        
        moreButton.setTitle("소식  더보기(\(viewModel.output.totalCount)개)", for: .normal)
        categoryImageView.setImage(urlString: viewModel.output.categoryIconUrl)
        storeNameLabel.text = viewModel.output.storeName
        updatedAtLabel.text = viewModel.output.timeStamp
        
        viewModel.output.isExpanded
            .main
            .sink { [weak self] isExpanded in
                guard let self else { return }
                
                updateTextView(viewModel.output.content, isExpanded: isExpanded)
            }
            .store(in: &cancellables)
    }
    
    func updateTextView(_ fullText: String, isExpanded: Bool) {
        if isExpanded {
            textView.attributedText = NSAttributedString(
                string: fullText,
                attributes: [
                    .font: Layout.contentTextFont,
                    .foregroundColor: Layout.contentTextColor
                ]
            )
        } else {
            let limitedText = getLimitedText(fullText: fullText)
            textView.attributedText = limitedText
        }
    }

    func getLimitedText(fullText: String, moreText: String = "더보기", maxLines: Int = 6) -> NSAttributedString {
        if textView.bounds.width == 0 {
            textView.layoutIfNeeded()
        }

        let textViewWidth = textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right
        let font = textView.font ?? Layout.contentTextFont
        let lineHeight = font.lineHeight
        let maxLines = maxLines

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraphStyle]
        let attributedText = NSAttributedString(string: fullText, attributes: attributes)

        let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: textViewWidth, height: CGFloat.greatestFiniteMagnitude), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
        let lines = CTFrameGetLines(frame) as! [CTLine]

        var origins = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)

        if lines.count <= maxLines {
            return attributedText
        }
        
        let truncatedText = NSMutableAttributedString()
        for i in 0..<maxLines - 1 {
            let lineRange = CTLineGetStringRange(lines[i])
            let lineText = attributedText.attributedSubstring(from: NSRange(location: lineRange.location, length: lineRange.length))
            truncatedText.append(lineText)
        }

        guard let line = lines[safe: maxLines - 1] else {
            return attributedText
        }
        
        let lastLineRange = CTLineGetStringRange(line)
        var lastLineText = attributedText.attributedSubstring(from: NSRange(location: lastLineRange.location, length: lastLineRange.length)).string
        
        let shortening = " ... "

        while (lastLineText + shortening + moreText).boundingRect(with: CGSize(width: textViewWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).height > lineHeight {
            lastLineText.removeLast()
        }

        let finalText = NSMutableAttributedString(string: lastLineText + shortening + moreText, attributes: attributes)
        finalText.addAttribute(.foregroundColor, value: Colors.gray40.color, range: NSRange(location: finalText.length - moreText.count, length: moreText.count))
        finalText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: finalText.length - moreText.count, length: moreText.count))

        truncatedText.append(finalText)

        return truncatedText
    }

    @objc func toggleTextView() {
        viewModel?.input.didTapContent.send()
    }
}

extension BossStorePostCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.imageUrls.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BossStorePostImageCell", for: indexPath) as! BossStorePostImageCell
        if let imageUrl = viewModel?.output.imageUrls[safe: indexPath.item] {
            cell.bind(imageUrl)
        }
        return cell
    }
}

extension BossStorePostCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let offset = collectionView.getNearByItemScrollOffset(velocity: velocity, targetContentOffset: targetContentOffset, sectionInsets: Layout.sectionInset) {
            targetContentOffset.pointee = offset
        }
    }
}

// MARK: - Image Cell
private final class BossStorePostImageCell: BaseCollectionViewCell {
    enum Layout {
        static let sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = Colors.gray70.color
        $0.layer.cornerRadius = 16
    }
    
    override func setup() {
        contentView.addSubview(imageView)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ imageUrl: String) {
        imageView.setImage(urlString: imageUrl)
    }
}
