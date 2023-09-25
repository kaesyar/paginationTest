//
//  ViewController.swift
//  PaginationTest
//
//  Created by Shakhzod Omonbayev on 22/09/23.
//

import UIKit

final class ViewController: UIViewController {
    private  var collectionView: UICollectionView!
    private  let presenter = Presenter()
    
    private let preloadOffset: Int = 5
    private let cellHeight = UIScreen.main.bounds.height / 10
    private let cellSpacing: CGFloat = 8.0
    private var isScrolling: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureCollectionView()
        presenter.loadData(page: .initial) { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.scrollToLatestMessage()
            }
        }
    }
    
    private func configureNavBar() {
        let container = UIView()
        container.frame = CGRect(x: .zero, y: .zero, width: view.frame.width, height: 44)
        
        let titleButton = UIButton(type: .custom)
        titleButton.setTitle("Pagination test", for: .normal)
        titleButton.setTitleColor(.blue, for: .normal)
        titleButton.frame = container.frame
        titleButton.addTarget(self, action: #selector(onTitleTap), for: .touchUpInside)
        container.addSubview(titleButton)
        self.navigationItem.titleView = container
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame = view.frame
        collectionView.allowsSelection = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .orange
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseIdentifier)
        self.view.addSubview(collectionView)
    }
    
    private func scrollToLatestMessage() {
        collectionView.scrollToItem(at: IndexPath(row: presenter.data.count - 1, section: .zero), at: .bottom, animated: false)
    }
    
    @objc private func onTitleTap() {
        // scrollToPinned Message
        presenter.loadData(page: .custom(elementNumber: 1000)) { dataCount in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(row: dataCount / 2, section: .zero), at: .centeredVertically, animated: true)
            }
        }
    }
}

// MARK:  - Collection Delegate and DataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        presenter.data.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCell.reuseIdentifier,
            for: indexPath
        ) as! MessageCell
        
        cell.configure(with: String(presenter.data[indexPath.row]) + " message")
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.row <= preloadOffset {
            presenter.loadData(page: .prev) { newDataCount in
                DispatchQueue.main.async {
                    collectionView.reloadData()
                    self.changeOffset(for: .prev, with: newDataCount)
                }
            }
        } else if indexPath.row  >= presenter.data.count - preloadOffset {
            presenter.loadData(page: .next) { newDataCount in
                DispatchQueue.main.async {
                    collectionView.reloadData()
                    self.changeOffset(for: .next, with: newDataCount)
                }
            }
        }
    }
    
    private func changeOffset(for loadType: PageLoadType, with count: Int) {
        let pagingVerticalOffset = self.computePagingOffset(for: count)
        let newVerticalOffset = loadType == .next ? self.currentOffset : self.currentOffset + pagingVerticalOffset
        collectionView.contentOffset = CGPoint(x: .zero, y: newVerticalOffset)
    }
}

// MARK: - Collection FlowLayout Delegate
extension ViewController: UICollectionViewDelegateFlowLayout {
    private var currentOffset: CGFloat {
        collectionView.contentOffset.y
    }
    
    private var collectionViewItemSize: CGSize {
        let width = collectionView.frame.width - cellSpacing * 2
        return CGSize(width: width, height: cellHeight)
    }
    
    private func computePagingOffset(for size: Int) -> CGFloat {
        CGFloat(size) * (cellHeight + cellSpacing)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionViewItemSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: cellSpacing, left: cellSpacing, bottom: cellSpacing, right: cellSpacing)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt
        section: Int
    ) -> CGFloat {
        cellSpacing
    }
}
