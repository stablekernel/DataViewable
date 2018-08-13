import UIKit

public protocol EmptyDataViewDelegate: class {
    func emptyDataViewWasPressed(_ EmptyDataView: EmptyDataView)
    func emptyDataViewDidPressButton(_ EmptyDataView: EmptyDataView)
    func emptyDataViewDidPressImage(_ EmptyDataView: EmptyDataView)
}

open class EmptyDataView: UIView {

    public lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.isUserInteractionEnabled = true
        return contentView
    }()

    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.systemFont(ofSize: 28.0)
        titleLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        return titleLabel
    }()

    public lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 18.0)
        detailLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        detailLabel.textAlignment = .center
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.numberOfLines = 0
        return detailLabel
    }()

    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .clear
        return imageView
    }()

    public lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        return button
    }()

    weak var delegate: EmptyDataViewDelegate?

    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    public init(delegate: EmptyDataViewDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: .zero)
        didLoad()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        didLoad()
    }

    open func prepareForReuse() {
        titleLabel.text = nil
        detailLabel.text = nil
        imageView.image = nil
        button.setImage(nil, for: .normal)
        button.setImage(nil, for: .highlighted)
        button.setAttributedTitle(nil, for: .normal)
        button.setAttributedTitle(nil, for: .highlighted)
        button.setBackgroundImage(nil, for: .normal)
        button.setBackgroundImage(nil, for: .highlighted)
    }

    open func didLoad() {
        setupConstraints()
        button.addTarget(self, action: #selector(didPressButtom(_:)), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didPress(_:)))
        addGestureRecognizer(tapGesture)

        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didPressImage(_:)))
        imageView.addGestureRecognizer(imageTapGesture)
    }

    // MARK: - Actions
    @objc open func didPressButtom(_ sender: UIButton) {
        delegate?.emptyDataViewDidPressButton(self)
    }

    @objc open func didPress(_ sender: UITapGestureRecognizer) {
        delegate?.emptyDataViewWasPressed(self)
    }

    @objc open func didPressImage(_ sender: UITapGestureRecognizer) {
        delegate?.emptyDataViewDidPressImage(self)
    }

    // MARK: - Layout
    open func setupConstraints() {

        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Setup Content view
        addSubview(contentView)

        let contentViewSideConstraints = [
            topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor),
            leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor),
            rightAnchor.constraint(greaterThanOrEqualTo: contentView.rightAnchor)
        ]

        // Empty view should focus on its intrinsic size more than edge constraints
        contentViewSideConstraints.forEach { $0.priority = .fittingSizeLevel - 1 }

        let contentViewCenterConstraints = [
            centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        contentViewCenterConstraints.forEach { $0.priority = .required }

        NSLayoutConstraint.activate(contentViewSideConstraints)
        NSLayoutConstraint.activate(contentViewCenterConstraints)

        // Setup stack views
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, detailLabel, button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12

        contentView.addSubview(stackView)

        let stackViewConstraints = [
            contentView.topAnchor.constraint(equalTo: stackView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: stackView.rightAnchor)
        ]

        NSLayoutConstraint.activate(stackViewConstraints)
        layoutIfNeeded()
    }
}
