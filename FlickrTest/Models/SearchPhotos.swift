//
//  SearchPhotos.swift
//  FlickrTest
//
//  Created by OkuderaYuki on 2016/12/17.
//  Copyright © 2016年 YukiOkudera. All rights reserved.
//

import UIKit

struct PhotoInfo {
    var id = ""
    var secret = ""
    var server = ""
    var farm = ""
}

struct PhotosInfo {
    var page = ""
    var pages = ""
    var parpage = ""
    var total = ""
    var photos = [PhotoInfo]()
}

private struct elementName {
    let id = "id"
    let secret = "secret"
    let server = "server"
    let farm = "farm"
}

class SearchPhotos: NSObject {
    
    fileprivate var photoInfo = PhotoInfo()
    fileprivate var photosInfo = PhotosInfo()
    
    func photoURL(photoInfo: PhotoInfo) -> String {
        return String(format: "https://farm%@.staticflickr.com/%@/%@_%@.jpg", photoInfo.farm, photoInfo.server, photoInfo.id, photoInfo.secret)
    }
    
    
    func search(text: String, page: Int, completionHandler: @escaping (PhotosInfo) -> Void) {
        let urlString = "https://api.flickr.com/services/rest/"
        let perPage = 50
        
        let params: [String: Any] = ["method": "flickr.photos.search",
                                     "per_page": perPage,
                                     "text": text,
                                     "page": page,
                                     "api_key": "10ba93bbe49a6480d765ce486673954a"]
        
        let apiClient = APIClient()
        
        apiClient.requestItems(urlString: urlString, params: params) { (response) in
            switch response {
            case .Success(let responseData):
                
                let responseData = responseData as! Data
                
                let xml = XMLParser(data: responseData)
                xml.delegate = self
                xml.parse()
                completionHandler(self.photosInfo)
                
            case .Error(let error):
                debugPrint("error:\(error)")
            }
        }
    }
    
}

extension SearchPhotos: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        photosInfo = PhotosInfo()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        guard let idString = attributeDict["id"], let secretString = attributeDict["secret"],
            let serverString = attributeDict["server"], let farmString = attributeDict["farm"] else {
                return
        }
        
        self.photoInfo = PhotoInfo()
        
        // スペースと改行を削除してphotoInfoにセット
        self.photoInfo.id = idString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.photoInfo.secret = secretString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.photoInfo.server = serverString.trimmingCharacters(in: .whitespacesAndNewlines)
        self.photoInfo.farm = farmString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.photosInfo.photos.append(self.photoInfo)
    }
}
