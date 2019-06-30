//
//  ViewController.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImageListViewController: UIViewController {
    let collectionViewPhotos: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()
    var page = 1
    var isPageRefreshing = false
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search image by tags"
        searchBar.text = "car"
        return searchBar
    }()
    var dispatchWorkItem: DispatchWorkItem?
    let imageSizeAndDownloadModel = ImagesSizeAndDownloadModel()
    var photos: [Photo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpCollectionView()
        setNavBar()
        fetchPhotoIds(tag: searchBar.text ?? "car")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Code to put while memory is low as we are storing images in model, it can take a lot if memory
        Caching.shared.cacheImage.removeAllObjects()
    }
    //MARK: - Fetch Pics
    func fetchPhotoIds(tag: String) {
        let apiPath = String(format: Api.fetchPhotos, Api.apiKeyFlicker, tag, page)
        print(apiPath)
        NetworkManager.getRequest(path: apiPath, success: { [weak self] (data) in
            let decoder = JSONDecoder.init()
            if let array = try? decoder.decode(PhotosResult.self, from: data).photos {
                if self?.isPageRefreshing == true {
                    DispatchQueue.main.async {
                        let count = self?.photos.count
                        self?.photos.append(contentsOf: array)
                        self?.collectionViewPhotos.performBatchUpdates({
                            for i in array.indices {
                                self?.collectionViewPhotos.insertItems(at: [IndexPath(row: i + (count ?? 0), section: 0)])
                            }
                        }, completion: { (success) in
                        })
                    }
                } else {
                    self?.photos = array
                    DispatchQueue.main.async {
                        self?.collectionViewPhotos.reloadData()
                    }
                }
            }
            self?.isPageRefreshing = false
        }) { [weak self] (error) in
            //handle when api fails
            if self?.page != 1 {
                self?.page -= 1
            }
            self?.isPageRefreshing = false
        }
    }
    //MARK: - Helper functions
    func setNavBar() {
        navigationItem.titleView = searchBar
    }
    func setUpCollectionView() {
        collectionViewPhotos.pin(to: view, topEdge: 0, bottomEdge: 0, leadingEdge: 0, trailingEdge: 0)
        collectionViewPhotos.delegate = self
        collectionViewPhotos.dataSource = self
        collectionViewPhotos.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    }
    func startOperations(indexPaths: Set<IndexPath>) {
        DispatchQueue.global(qos: .userInteractive).async {
            for indexPath in indexPaths {
                self.imageSizeAndDownloadModel.startOperations(photo: self.photos[indexPath.row], indexPath: indexPath) { [weak self] (indexpath) in
                    //update row
                    let photo = self?.photos[indexpath.row]
                    if photo?.state == .downloaded {
                        self?.dispatchWorkItem?.cancel()
                        self?.dispatchWorkItem = DispatchWorkItem.init(block: {
                            self?.collectionViewPhotos.reloadData()
                        })
                        if let dispatchItem = self?.dispatchWorkItem {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: dispatchItem)
                        }
                    } else {
                        self?.startOperations(indexPaths: [indexpath])
                    }
                }
            }
        }
    }
}
extension ImageListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        if let url = photo.url, let image = Caching.shared.cacheImage.object(forKey: url as NSURL) {
            cell.imageViewPhoto.image = image
            return cell
        } else {
            cell.imageViewPhoto.image = #imageLiteral(resourceName: "placeholder")
        }
        switch (photo.state!) {
        case .sizeFetched, .new:
            if !collectionView.isDragging && !collectionView.isDecelerating {
                startOperations(indexPaths: [indexPath])
            }
        case .downloaded:
            if let url = photo.url, Caching.shared.cacheImage.object(forKey: url as NSURL) == nil {
                photo.state = PhotoState.sizeFetched
                if !collectionView.isDragging && !collectionView.isDecelerating {
                    startOperations(indexPaths: [indexPath])
                }
            }
        default:
            break
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = photos[indexPath.row].url, let image = Caching.shared.cacheImage.object(forKey: url as NSURL){
            let imageDetailVC = ImageDetailViewController()
            imageDetailVC.imageViewPhoto.image = image
            navigationController?.pushViewController(imageDetailVC, animated: true)
        }
    }
}
extension ImageListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width/2, height: collectionView.frame.size.width/2)
    }
}
extension ImageListViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageSizeAndDownloadModel.suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let startOperationIndexPaths = imageSizeAndDownloadModel.loadImagesForOnscreenCells(visibleCellIndexPaths: collectionViewPhotos.indexPathsForVisibleItems)
            startOperations(indexPaths: startOperationIndexPaths)
            imageSizeAndDownloadModel.resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let startOperationIndexPaths = imageSizeAndDownloadModel.loadImagesForOnscreenCells(visibleCellIndexPaths: collectionViewPhotos.indexPathsForVisibleItems)
        startOperations(indexPaths: startOperationIndexPaths)
        imageSizeAndDownloadModel.resumeAllOperations()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //if user has reached till the bottom then fetch another page
        if(self.collectionViewPhotos.contentOffset.y >= (self.collectionViewPhotos.contentSize.height - self.collectionViewPhotos.bounds.size.height)) {
            if(isPageRefreshing==false) {
                isPageRefreshing=true
                page = page + 1
                fetchPhotoIds(tag: searchBar.text ?? "car")
            }
        }
    }
}
extension ImageListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, text.count > 0 {
            page = 1
            fetchPhotoIds(tag: text)
            searchBar.resignFirstResponder()
        }
    }
}
