import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailNewsCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(viewModel: StoreDetailNewsCellViewModel, width: CGFloat) -> CGFloat {
            guard let news = viewModel.output.news else { return 0 }
            var totalHeight: CGFloat = 0
            
            let sectionHeaderHeight: CGFloat = 24
            totalHeight += sectionHeaderHeight
            totalHeight += 12 // 섹션 헤더 하단 패딩
            
            let headerHeight: CGFloat = 68
            totalHeight += headerHeight
            
            if news.images.isNotEmpty {
                totalHeight += StoreDetailNewsImageCell.Layout.height
                totalHeight += 12 // 이미지 하단 패딩
            }
            
            var contentHeight = news.content.text.boundingRect(
                with: CGSize(
                    width: width - sectionInset.left - sectionInset.right,
                    height: CGFloat.greatestFiniteMagnitude
                ),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [
                    .font: Fonts.regular.font(size: 14)
                ],
                context: nil
            ).height + 20
            
            let expendContent = viewModel.output.expendContent.value
            
            if expendContent.isNot && isMoreThanMaxLine(body: news.content.text) {
                contentHeight = 116
            }
            
            totalHeight += contentHeight
            totalHeight += 12 // 컨텐츠 하단 패딩
            
            let likeButtonHeight: CGFloat = 16
            totalHeight += likeButtonHeight
            totalHeight += 16 // 좋아요 버튼 하단 패딩
            
            return totalHeight
        }
        
        static func isMoreThanMaxLine(body: String) -> Bool {
            let textView = UITextView()
            textView.textContainer.lineFragmentPadding = 0
            textView.font = Layout.contentTextFont
            textView.layoutIfNeeded()
            
            let textViewWidth = UIUtils.windowBounds.width - 48
            let font = textView.font ?? Layout.contentTextFont
            let lineHeight = font.lineHeight
            let maxLines = 6
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraphStyle]
            let attributedText = NSAttributedString(string: body, attributes: attributes)
            
            let framesetter = CTFramesetterCreateWithAttributedString(attributedText)
            let path = CGPath(rect: CGRect(x: 0, y: 0, width: textViewWidth, height: CGFloat.greatestFiniteMagnitude), transform: nil)
            let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
            let lines = CTFrameGetLines(frame) as! [CTLine]
            
            var origins = [CGPoint](repeating: .zero, count: lines.count)
            CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
            
            return lines.count > maxLines
        }
        
        static let sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let contentTextFont = Fonts.regular.font(size: 14)
        static let contentTextColor = Colors.gray95.color
    }
    
    private let headerView = StoreDetailHeaderView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let categoryImageView = UIImageView()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let updatedAtLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 12)
        label.textColor = Colors.gray40.color
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.font = Layout.contentTextFont
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.medium.font(size: 10)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 2)
        return button
    }()
    
    private let tapGesture = UITapGestureRecognizer()
    private weak var viewModel: StoreDetailNewsCellViewModel?
    
    override func setup() {
        setupUI()
        textView.addGestureRecognizer(tapGesture)
        tapGesture.addTarget(self, action: #selector(toggleTextView))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            BaseCollectionViewCell.self,
            StoreDetailNewsImageCell.self
        ])
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubview(headerView)
        contentView.addSubview(containerView)
        containerView.addSubview(categoryImageView)
        containerView.addSubview(storeNameLabel)
        containerView.addSubview(updatedAtLabel)
        containerView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(collectionView)
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(likeButton)

        headerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(12)
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
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(StoreDetailNewsImageCell.Layout.height)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.height.equalTo(16)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = Layout.sectionInset
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
    
    func bind(_ viewModel: StoreDetailNewsCellViewModel) {
        setHeaderView(header: viewModel.output.header)
        if let news = viewModel.output.news {
            setNews(news: news)
        }
        
        self.viewModel = viewModel
        
        // Input
        headerView.rightButton.tapPublisher
            .subscribe(viewModel.input.didTapMore)
            .store(in: &cancellables)
        
        likeButton.tapPublisher
            .handleEvents(receiveOutput: { _ in
                FeedbackGenerator.shared.generate(.impact)
            })
            .subscribe(viewModel.input.didTapLike)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.expendContent
            .main
            .sink { [weak self] (isExpanded: Bool) in
                guard let content = viewModel.output.news?.content.text else { return }
                
                self?.updateTextView(content, isExpanded: isExpanded)
            }
            .store(in: &cancellables)
        
        viewModel.output.sticker
            .compactMap { $0 }
            .main
            .sink { [weak self] (likeSection: StoreNewsSectionResponse.StoreNewsCardSectionResponse.LikeSectionResponse) in
                self?.setLikeButton(likeSection)
            }
            .store(in: &cancellables)
    }
    
    private func setHeaderView(header: HeaderSectionResponse) {
        headerView.bind(header: header)
        headerView.snp.updateConstraints {
            $0.height.equalTo(StoreDetailHeaderView.Layout.calculateHeight(header: header))
        }
    }
    
    private func setNews(news: StoreNewsSectionResponse.StoreNewsCardSectionResponse) {
        if let thumbnail = news.thumbnail {
            categoryImageView.setImage(urlString: thumbnail.url)
        }
        
        storeNameLabel.setSDText(news.title)
        if let subTitle = news.subTitle {
            updatedAtLabel.setSDText(subTitle)
        }
        
        collectionView.isHidden = news.images.isEmpty
        
        if let likeButton = news.likeButton {
            setLikeButton(likeButton)
        }
        
        if self.viewModel != viewModel {
            collectionView.reloadData()
            DispatchQueue.main.async { [weak self] in
                guard let scrollOffset = self?.viewModel?.output.scrollOffset.value else { return }
                
                self?.collectionView.setContentOffset(scrollOffset, animated: true)
            }
        }
    }
    
    private func setLikeButton(_ likeSection: StoreNewsSectionResponse.StoreNewsCardSectionResponse.LikeSectionResponse) {
        
        if likeSection.isSelected {
            let image = Icons.heartFill.image
                .resizeImage(scaledTo: 16)
                .withRenderingMode(.alwaysTemplate)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = Colors.mainRed.color
            likeButton.setTitleColor(Colors.mainRed.color, for: .normal)
        } else {
            let image = Icons.heartLine.image
                .resizeImage(scaledTo: 16)
                .withRenderingMode(.alwaysTemplate)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = Colors.gray60.color
            likeButton.setTitleColor(Colors.gray60.color, for: .normal)
        }
        likeButton.setSDButton(likeSection.button)
    }
    
    private func updateTextView(_ fullText: String, isExpanded: Bool) {
        if isExpanded {
            textView.attributedText = NSAttributedString(
                string: fullText,
                attributes: [
                    .font: Layout.contentTextFont,
                    .foregroundColor: Layout.contentTextColor
                ]
            )
        } else {
            let limitedText = getLimitedText(
                fullText: fullText,
                moreText: viewModel?.output.moreButton?.text ?? "더보기"
            )
            textView.attributedText = limitedText
        }
    }
    
    private func getLimitedText(fullText: String, moreText: String = "더보기", maxLines: Int = 6) -> NSAttributedString {
        if textView.bounds.width == 0 {
            textView.layoutIfNeeded()
        }
        
        let textViewWidth = UIUtils.windowBounds.width - Layout.sectionInset.left - Layout.sectionInset.right
        
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

extension StoreDetailNewsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.news?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = viewModel?.output.news?.images[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: StoreDetailNewsImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(sdImage: image)
        return cell
    }
}

extension StoreDetailNewsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let image = viewModel?.output.news?.images[safe: indexPath.item] else {
            return CGSize(width: StoreDetailNewsImageCell.Layout.height, height: StoreDetailNewsImageCell.Layout.height)
        }
        
        let ratio = image.style.width / image.style.height
        let width = StoreDetailNewsImageCell.Layout.height * ratio
        let height = StoreDetailNewsImageCell.Layout.height
        
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel?.input.didScroll.send(scrollView.contentOffset)
    }
}
