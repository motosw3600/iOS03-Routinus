//
//  AuthListViewController.swift
//  Routinus
//
//  Created by 백지현 on 2021/11/24.
//

import Combine
import UIKit

class AuthListViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AuthListCollectionViewCell.self,
                                forCellWithReuseIdentifier: AuthListCollectionViewCell.identifier)
        return collectionView
    }()

    private var viewModel: AuthListViewModelIO?
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AuthListViewModelIO) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureDelegates()
        configureViewModels()
    }
}

extension AuthListViewController {
    private func configureViews() {
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(collectionView)

        // TODO: autolayout 수정
        collectionView.anchor(leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              top: view.topAnchor,
                              bottom: view.bottomAnchor)
    }

    private func configureDelegates() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    private func configureViewModels() {
        self.viewModel?.auths
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }
}

extension AuthListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.auths.value.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AuthListCollectionViewCell.identifier,
                                                            for: indexPath) as? AuthListCollectionViewCell else { return UICollectionViewCell() }

        guard let auth = viewModel?.auths.value[indexPath.item], let date = auth.date?.toDateString() else { return UICollectionViewCell() }
        let filename = "\(auth.userID)_\(date)_thumbnail_auth"
        viewModel?.imageData(from: auth.challengeID,
                            filename: filename) { data in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                cell.update(image: image)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 
        return CGSize(width: width, height: width)
    }
}
