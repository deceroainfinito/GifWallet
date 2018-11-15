//
//  Created by Pierluigi Cifani on 10/03/2018.
//  Copyright © 2018 Code Crafters. All rights reserved.
//

import GifWalletKit

protocol GIFDetailPresenterType {
    func fetchGifDetails(gifID: String, handler: @escaping (GIFDetailsViewController.VM?) -> Void)
}

extension GIFDetailsViewController {

    class Presenter: GIFDetailPresenterType {

        let dataStore: DataStore
        
        init(dataStore: DataStore) {
            self.dataStore = dataStore
        }
        
        func fetchGifDetails(gifID: String, handler: @escaping (GIFDetailsViewController.VM?) -> Void) {
            guard let _managedGIF = try? self.dataStore.fetchGIF(id: gifID),
                let managedGIF = _managedGIF else {
                    handler(nil)
                    return
            }
            
            guard let giphyID = managedGIF.giphyID,
                let title = managedGIF.title,
                let subtitle = managedGIF.subtitle,
                let urlString = managedGIF.remoteURL,
                let url = URL(string: urlString)
                else {
                    handler(nil)
                    return
            }
            
            let vm = GIFDetailsViewController.VM(gifID: giphyID, title: title, url: url, subtitle: subtitle, tags: managedGIF.tags)
            handler(vm)
        }
    }
    
    class MockDataPresenter: GIFDetailPresenterType {
        
        var delaySeconds: Int = 1
        
        func fetchGifDetails(gifID: String, handler: @escaping (GIFDetailsViewController.VM?) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delaySeconds)) {
                handler(MockLoader.mockDetailGif(gifID: gifID))
            }
        }
    }
}

