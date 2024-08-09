import UIKit
import SnapKit
import Alamofire
import Kingfisher
import SwiftyJSON

class HashTagSearchResultViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
        
    let cellName1 = "collectionViewCell1"
    let lastCell = "LastSafeCircleCell"
    
    let view1 = UIView()
    let view2 = UIView()
    let view3 = UIView()
    
    var heroes: [HashtagList3] = []
    var noreceivedValueFromBeforeVC = ""
    
    var previousCollectionView: UICollectionView?
    var collectionViewImages: [[String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.centerX.top.bottom.equalToSuperview()
        }
        
        self.contentView.addSubview(view1)
        self.contentView.addSubview(view2)
        self.contentView.addSubview(view3)
        
        self.fetchData()
        
        previousCollectionView?.snp.makeConstraints { (make) in
            make.bottom.lessThanOrEqualTo(contentView.snp.bottom).offset(-20)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.bottom.equalTo(previousCollectionView?.snp.bottom ?? contentView.snp.bottom).offset(80)
        }
        
        view1.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(previousCollectionView?.snp.bottom ?? contentView.snp.top).offset(20)
        }
        
        view2.snp.makeConstraints { (make) in
            make.top.equalTo(view1.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        //view3.backgroundColor = .gray
        view3.snp.makeConstraints { (make) in
            make.top.equalTo(view2.snp.bottom)
            make.leading.trailing.equalToSuperview()
            //make.height.equalTo(300)
            make.bottom.equalToSuperview()
        }
    }
    
    func fetchData() {
        let url = NetworkProtocol.SEARCH_RESULT
        
        let parameters: Parameters = [
            "gbn": "4",
            "keyword": "\(noreceivedValueFromBeforeVC)",
            "page": "1"
        ]
        print("해시태그 검색결과 parameters:", parameters)
        
        AF.request(url, method: .get, parameters: parameters, headers: nil).responseJSON(completionHandler: { response in
            
            let json = response.result
            print("해시태그 검색결과 json:", json)
            
            switch response.result {
            case .success(let res):
                
                if let JSON = response.value {
                    print("해시태그 검색결과 JSON:", JSON)
                }
                
                if response.value != nil {
                    
                    let jsondata = JSON(response.value!)
                    print("해시태그 검색결과 resn:", jsondata["RESN"])
                    print("해시태그 검색결과 result:", jsondata["RSLT"])
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SearchResultHashTag.self, from: jsonData)
                    //self.heroes = json.data!.hashtagList
                    self.heroes = json.data?.hashtagList ?? []
                    print("self.heroes", self.heroes)
                    
                    for hero in self.heroes {
                        print("Hero ID1: \(hero.id ?? 0), TagName: \(hero.tagName ?? "Unknown")")
                    }
                    
                    self.previousCollectionView?.dataSource = self
                    self.previousCollectionView?.reloadData()
                    self.setupCollectionView()
                    
                    self.heroes.forEach { e in
                    }
                    
                    if self.heroes.isEmpty {
                        let image = UIImage(named: "img_ic_account_nosearch")
                        let messageImageView = UIImageView(image: image)
                        messageImageView.contentMode = .scaleAspectFit
                        self.view.addSubview(messageImageView)
                        
                        messageImageView.snp.makeConstraints { (make) in
                            make.centerX.equalToSuperview()
                            make.top.equalTo(154)
                            make.width.equalTo(69)
                            make.height.equalTo(62)
                        }
                        
                        let titleLabel = UILabel()
                        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                        titleLabel.textColor = UIColor.black
                        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
                        titleLabel.text = "결과 없음"
                        self.view.addSubview(titleLabel)
                        
                        titleLabel.snp.makeConstraints{ (make) in
                            make.centerX.equalToSuperview()
                            make.top.equalTo(messageImageView.snp.bottom).offset(30)
                        }
                        
                        let messageLabel = UILabel()
                        messageLabel.textColor = UIColor.lightGray
                        messageLabel.font = UIFont.systemFont(ofSize: 13)
                        messageLabel.translatesAutoresizingMaskIntoConstraints = false
                        messageLabel.numberOfLines = 0
                        messageLabel.text = "다른 검색어를 입력해 주세요."
                        messageLabel.textAlignment = .center
                        self.view.addSubview(messageLabel)
                        
                        messageLabel.snp.makeConstraints{ (make) in
                            make.centerX.equalToSuperview()
                            make.top.equalTo(titleLabel.snp.bottom).offset(4)
                        }
                    }
                    
                } catch {
                    print("Error parsing JSON:", error)
                }
                
            case .failure(let err):
                print("Fetch failed with error:", err)
                
                if err.localizedDescription == "URLSessionTask failed with error: Could not connect to the server." {
                    let alert = UIAlertController(title: "알림", message: "서버와의 연결이 끊어졌습니다.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                if err.localizedDescription == "A data connection is not currently allowed." {
                    let alert = UIAlertController(title: "알림", message: "와이파이 혹은 네트워크 연결상태를 확인해 주세요.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                if err.localizedDescription == "The request timed out." {
                    let alert = UIAlertController(title: "알림", message: "서버 응답 시간 초과", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                let alert = UIAlertController(title: "알림", message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func setupCollectionView() {
        //var previousCollectionView: UICollectionView?
        var previousTitleLabel: UILabel?
        
        for (index, hero) in heroes.enumerated() {
            var imageURLs: [String] = []
            
            if let imageURL = hero.image {
                if index < collectionViewImages.count {
                    collectionViewImages[index] = [imageURL]
                } else {
                    collectionViewImages.append([imageURL])
                }
                imageURLs.append(imageURL)
            }
            collectionViewImages[index] = imageURLs
            
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textColor = UIColor.black
            titleLabel.text = hero.tagName
            contentView.addSubview(titleLabel)
            
            let collectionView: UICollectionView = {
                let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
                collectionView.showsVerticalScrollIndicator = false
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.tag = index
                
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
                layout.itemSize = CGSize(width: 110, height: 200)
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
                layout.scrollDirection = .horizontal
                
                collectionView.setCollectionViewLayout(layout, animated: false)
                return collectionView
            }()
            contentView.addSubview(collectionView)
            
            titleLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(16)
                if let previousTitleLabel = previousTitleLabel {
                    print(previousTitleLabel)
                    make.top.equalTo(previousCollectionView!.snp.bottom).offset(20)
                } else {
                    make.top.equalToSuperview().offset(56)
                }
                make.right.equalTo(-10)
            }
            
            collectionView.backgroundColor = UIColor.white
            collectionView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(13)
                make.leading.equalTo(12)
                make.trailing.equalTo(-12)
                make.height.equalTo(152)
            }
            
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            collectionView.setContentCompressionResistancePriority(.required, for: .vertical)
            
            previousTitleLabel = titleLabel
            previousCollectionView = collectionView
            
            if index == heroes.count - 1 {
                collectionView.snp.makeConstraints { (make) in
                    make.bottom.lessThanOrEqualTo(contentView.snp.bottom).offset(-20)
                }
            }
            
            self.previousCollectionView?.dataSource = self
            self.previousCollectionView?.delegate = self
            
            self.previousCollectionView?.register(SearchResultHashTagCollectionViewCell.self, forCellWithReuseIdentifier: self.cellName1)
            self.previousCollectionView?.register(ViewMoreCollectionViewCell.self, forCellWithReuseIdentifier: self.lastCell)
            self.previousCollectionView?.reloadData()
        }
    }
}

extension HashTagSearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func initCollectionView() {
        self.previousCollectionView?.dataSource = self
        self.previousCollectionView?.delegate = self
        self.previousCollectionView?.register(SearchResultHashTagCollectionViewCell.self, forCellWithReuseIdentifier: self.cellName1)
        self.previousCollectionView?.register(ViewMoreCollectionViewCell.self, forCellWithReuseIdentifier: self.lastCell)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == collectionViewImages[collectionView.tag].count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.lastCell, for: indexPath) as! ViewMoreCollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellName1, for:indexPath) as! SearchResultHashTagCollectionViewCell
            
            let imageURL = collectionViewImages[collectionView.tag][indexPath.row]
            let imageURL2 = imageURL
            let url2 : URL! = URL(string: imageURL2)
            cell.userImage.kf.setImage(with: url2)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == collectionViewImages[collectionView.tag].count {
            print("마지막 셀 클릭됨")
            let vc = SearchPageContentsViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.hidesBottomBarWhenPushed = true
            vc.transitioningDelegate = self
            vc.noreceivedValueFromBeforeVC = self.heroes[indexPath.row].tagName
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? ViewMoreCollectionViewCell {
                // ViewMoreCollectionViewCell이 클릭된 경우
                print("ViewMoreCollectionViewCell 클릭됨")
                
                let vc = SearchPageContentsViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.hidesBottomBarWhenPushed = true
                vc.transitioningDelegate = self
                vc.noreceivedValueFromBeforeVC = self.heroes[indexPath.row].tagName
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            } else if let cell = collectionView.cellForItem(at: indexPath) as? SearchResultHashTagCollectionViewCell {
                // SearchResultHashTagCollectionViewCell이 클릭된 경우
                print("SearchResultHashTagCollectionViewCell 클릭됨")
                
                let vc = VideoDetailViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.hidesBottomBarWhenPushed = true
                vc.transitioningDelegate = self
                
                /*let x1: Int? = self.heroes[indexPath.row].id
                let b2 = x1.map(String.init) ?? ""
                vc.noreceivedValueFromBeforeVC = b2*/
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                print("Cell \(indexPath.item) 클릭됨")
            }
        }
    }
}

extension HashTagSearchResultViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView.tag < collectionViewImages.count else {
            print("Invalid collection view tag.")
            return 0
        }
        
        return min(collectionViewImages[collectionView.tag].count + 1, 4)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == collectionViewImages[collectionView.tag].count {
            return CGSize(width: 50, height: collectionView.bounds.height)
        } else {
            let size = CGSize(width: 102, height: 152)
            return size
        }
    }
}

extension UICollectionView {
    func setEmptyView(title: String, message: String, messageImage: UIImage) {
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyView.backgroundColor = .clear
        
        let messageImageView = UIImageView()
        messageImageView.backgroundColor = .clear
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        let messageLabel = UILabel()
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageImageView)
        emptyView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            messageImageView.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 154),
            messageImageView.widthAnchor.constraint(equalToConstant: 69),
            messageImageView.heightAnchor.constraint(equalToConstant: 62),
            
            titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: messageImageView.bottomAnchor, constant: 30),
            
            messageLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        
        messageImageView.image = messageImage
        titleLabel.text = title
        messageLabel.text = message
        
        self.backgroundView = emptyView
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension HashTagSearchResultViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
