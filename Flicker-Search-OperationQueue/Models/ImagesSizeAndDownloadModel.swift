//
//  ImagesSizeAndDownloader.swift
//  Flicker-Search-OperationQueue
//
//  Created by Vishnu Agarwal on 27/06/19.
//  Copyright © 2019 Vishnu Agarwal. All rights reserved.
//

import UIKit

class ImagesSizeAndDownloadModel {
    lazy var sizingInProgress: [IndexPath: Operation] = [:]
    lazy var sizingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Sizing Queue"
        return queue
    }()
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Download Queue"
        return queue
    }()
    func suspendAllOperations() {
        sizingQueue.isSuspended = true
        downloadQueue.isSuspended = true
    }
    func resumeAllOperations() {
        sizingQueue.isSuspended = false
        downloadQueue.isSuspended = false
    }
    func loadImagesForOnscreenCells(visibleCellIndexPaths: [IndexPath]) -> Set<IndexPath> {
        var pendingOperations = Set(downloadsInProgress.keys)
        pendingOperations.formUnion(sizingInProgress.keys)
        
        // subtracting the visible indexpaths from paths which are supposed to be cancelled
        var cancellableOperations = pendingOperations
        let visiblePaths = Set(visibleCellIndexPaths)
        cancellableOperations.subtract(visiblePaths)
        
        // getting the paths which are not pending and has to start operations
        var toBeStarted = visiblePaths
        toBeStarted.subtract(pendingOperations)
        
        for indexPath in cancellableOperations {
            //remove download
            if let pendingDownload = downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            downloadsInProgress.removeValue(forKey: indexPath)
            //remove fetching size
            if let pendingSizing = sizingInProgress[indexPath] {
                pendingSizing.cancel()
            }
            sizingInProgress.removeValue(forKey: indexPath)
        }
        return toBeStarted
    }
    func startOperations(photo: Photo, indexPath: IndexPath, completionBlock: @escaping (IndexPath)-> Void) {
        guard let state = photo.state else { return }
        switch (state) {
        case .sizeFetched:
            startDownload(photo: photo, indexPath: indexPath, completionBlock: completionBlock)
        case .new:
            startFetchSize(photo: photo, indexPath: indexPath, completionBlock: completionBlock)
        case .failed:
            if photo.url == nil {
                startFetchSize(photo: photo, indexPath: indexPath, completionBlock: completionBlock)
            } else {
                startDownload(photo: photo, indexPath: indexPath, completionBlock: completionBlock)
            }
        default:
            break
        }
    }
    func startDownload(photo: Photo, indexPath: IndexPath, completionBlock: @escaping (IndexPath)-> Void) {
        guard downloadsInProgress[indexPath] == nil else {
            return
        }

        let downloader = ImageDownloader(photo)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
                self.downloadsInProgress.removeValue(forKey: indexPath)
                completionBlock(indexPath)
        }
        downloadsInProgress[indexPath] = downloader
        downloadQueue.addOperation(downloader)
    }
    func startFetchSize(photo: Photo, indexPath: IndexPath, completionBlock: @escaping (IndexPath)-> Void) {
        guard sizingInProgress[indexPath] == nil else {
            return
        }
        
        let fetcher = ImageSizeFetcher(photo)
        
        fetcher.completionBlock = {
            if fetcher.isCancelled {
                return
            }
                self.sizingInProgress.removeValue(forKey: indexPath)
                completionBlock(indexPath)
        }
        sizingInProgress[indexPath] = fetcher
        sizingQueue.addOperation(fetcher)
    }

}
