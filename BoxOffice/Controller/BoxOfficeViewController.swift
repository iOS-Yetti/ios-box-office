//
//  ViewController.swift
//  BoxOffice
//
//  Created by Yetti, Maxhyunm on 2023/07/24.
//

import UIKit

final class BoxOfficeViewController: UIViewController, URLSessionDelegate {
    private var networkingManager: NetworkingManager?
    private var refreshControl = UIRefreshControl()
    private var dataSource: UICollectionViewDiffableDataSource<NetworkConfiguration, BoxOfficeEntity.BoxOfficeResult.DailyBoxOffice>?
    
    private let collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(BoxOfficeRankingCell.self, forCellWithReuseIdentifier: BoxOfficeRankingCell.cellIdentifier)

        return view
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.style = .large
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        return indicatorView
    }()
    
    private var isLoading: Bool = true {
        willSet(newValue) {
            if newValue == true {
                indicatorView.isHidden = false
                indicatorView.startAnimating()
            } else {
                indicatorView.isHidden = true
                indicatorView.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        isLoading = true
        setUpUI()
        setUpCollectionView()
        setUpDataSource()
        setUpNetwork()
        passFetchedData()
    }
}

extension BoxOfficeViewController {
    private func setUpUI() {
        let safeArea = view.safeAreaLayoutGuide
        let dateSelectionButton = UIBarButtonItem(title: "날짜선택", style: .plain, target: self, action: #selector(showCalendar))
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(indicatorView)
        
        self.title = getDate()
        self.navigationItem.rightBarButtonItem = dateSelectionButton
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            
            indicatorView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    private func getDate() -> String {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return ""
        }
        
        return DateFormatter().formatToString(from: yesterday, with: "YYYY-MM-dd")
    }
    
    @objc func showCalendar(_ sender: UIButton) {
        let viewController = CalendarViewController()
        viewController.modalPresentationStyle = UIModalPresentationStyle.automatic
        
        self.present(viewController, animated: true)
    }
}

extension BoxOfficeViewController {
    private func setUpCollectionView() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<NetworkConfiguration, BoxOfficeEntity.BoxOfficeResult.DailyBoxOffice>(collectionView: self.collectionView) { (collectionView, indexPath, data) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoxOfficeRankingCell.cellIdentifier, for: indexPath) as? BoxOfficeRankingCell else {
                return UICollectionViewCell()
            }
            
            cell.setUpLabelText(data)
            
            return cell
        }
    }
    
    private func setUpDataSnapshot(_ data: [BoxOfficeEntity.BoxOfficeResult.DailyBoxOffice]) {
        let date = getDate().replacingOccurrences(of: "-", with: "")
        var snapshot = NSDiffableDataSourceSnapshot<NetworkConfiguration, BoxOfficeEntity.BoxOfficeResult.DailyBoxOffice>()
        
        snapshot.appendSections([.boxOffice(date)])
        snapshot.appendItems(data)
        dataSource?.apply(snapshot)
    }
    
    @objc private func refresh() {
        passFetchedData()
    }
}

extension BoxOfficeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieCode = dataSource?.itemIdentifier(for: indexPath)?.movieCode,
              let movieName = dataSource?.itemIdentifier(for: indexPath)?.movieName else {
            return
        }
        
        let movieDetailViewController = MovieDetailViewController(movieCode: movieCode, movieName: movieName)
        
        navigationController?.pushViewController(movieDetailViewController, animated: true)
    }
}

extension BoxOfficeViewController {
    private func setUpNetwork() {
        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            
            return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }()
        
        networkingManager = NetworkingManager(session)
    }
    
    private func passFetchedData() {
        let date = getDate().replacingOccurrences(of: "-", with: "")

        networkingManager?.load(NetworkConfiguration.boxOffice(date)) { [weak self] (result: Result<Data, NetworkingError>) in
            switch result {
            case .success(let data):
                do {
                    let decodedData: BoxOfficeEntity = try DecodingManager.shared.decode(data)
                    self?.setUpDataSnapshot(decodedData.boxOfficeResult.dailyBoxOfficeList)
                } catch {
                    print(DecodingError.decodingFailure.description)
                }
            case .failure(let error):
                print(error.description)
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.refreshControl.endRefreshing()
            }
        }
    }
}
