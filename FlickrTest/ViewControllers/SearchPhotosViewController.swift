//
//  SearchPhotosViewController.swift
//  FlickrTest
//
//  Created by OkuderaYuki on 2016/12/17.
//  Copyright © 2016年 YukiOkudera. All rights reserved.
//

import UIKit
import ReachabilitySwift

class SearchPhotosViewController: UIViewController {
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    fileprivate var photosInfo = PhotosInfo()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - IBAction
    @IBAction func tappedSearchButton(_ sender: Any) {
        
        // 検索ボタン押下時にキーボードを表示していた場合は閉じる
        if searchTextField.isEditing {
            searchTextField.resignFirstResponder()
        }
        
        // オフライン確認
        self.checkOffline()
        
        guard let searchText = searchTextField.text else {
            return
        }
        
        let searchPhotos = SearchPhotos()
        
        // TODO: ページ制御(とりあえず1セット)
        searchPhotos.search(text: searchText, page: 1) { (photosInfo) in
            self.photosInfo = photosInfo
            self.photosCollectionView.reloadData()
            // 検索結果0件確認
            self.checkSearchResultZero()
        }
    }
}

// MARK: - SearchPhotosViewController Extension
extension SearchPhotosViewController {
    
    fileprivate func setup() {
        searchButton.isEnabled = false
        
        photosCollectionView.dataSource = self
        searchTextField.delegate = self
    }
    
    fileprivate func checkOffline() {
        let reachability = Reachability()!
        if (reachability.currentReachabilityStatus == .notReachable) {
            let offlineMessage = "ネットワーク環境の良い環境で再度お試しください。"
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: offlineMessage,
                                                             preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func checkSearchResultZero() {
        if self.photosInfo.photos.count == 0 {
            let noImageMessage = "該当する写真がありません。検索ワードを変更してお試しください。"
            let alert: UIAlertController = UIAlertController(title: "",
                                                             message: noImageMessage,
                                                             preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchPhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosInfo.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.activityIndicator.isHidden = false
        cell.activityIndicator.startAnimating()
        
        // cell再利用時の画像リセット対応
        cell.imageView.image = nil
        
        let searchPhotos = SearchPhotos()
        let urlString = searchPhotos.photoURL(photoInfo: self.photosInfo.photos[indexPath.row])
        cell.imageURLString = urlString
        
        DispatchQueue.global(qos: .default).async {
            guard let url = URL(string: urlString) else {
                return
            }
            let imageData = try! Data(contentsOf: url)
            guard let image = UIImage(data: imageData) else {
                return
            }
            
            DispatchQueue.main.async {
                if urlString == cell.imageURLString {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageView.image = image
                }
            }
        }
        
        return cell;
    }
}

// MARK: - UITextFieldDelegate
extension SearchPhotosViewController: UITextFieldDelegate {
    
    /// Doneタップでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let length = textFieldText.characters.count - range.length + string.characters.count
            debugPrint("length:\(length)")
            
            // 未入力でなければ、検索ボタンをenableにする
            searchButton.isEnabled = (length != 0)
        }
        
        return true
    }
}
