//
//  SavedGifsViewController.swift
//  GifMaker
//
//  Created by Abad Vera on 10/18/16.
//  Copyright © 2016 Abad Vera. All rights reserved.
//

import UIKit

var gifsFilePath: String {
    let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let directory = directories.first
    let gifsPath = directory?.appending("/savedGifs")
    return gifsPath!
}


class SavedGifsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PreviewViewControllerDelegate {
    
    var savedGifs: [Gif]? = [Gif]()
    let cellMargin = CGFloat(12.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIStackView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide if there are no savedGifs
        if let count = savedGifs?.count {
            emptyView.isHidden = count > 0 ? true : false
        }
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to see if we need to show welcome screen
        showWelcome()
        
        if let archGifs = NSKeyedUnarchiver.unarchiveObject(withFile: gifsFilePath) as? [Gif] {
            savedGifs = archGifs
        }
    }
    
    func showWelcome() {
        if UserDefaults.standard.bool(forKey: "WelcomeViewSeen") != true {
            let welcomeVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            self.navigationController?.pushViewController(welcomeVC, animated: true)
        }
    }
    
    // MARK: PreviewVC Delegate methods
    
    func previewVC(preview: PreviewViewController, didSaveGif gif: Gif) {
        gif.gifData = NSData(contentsOf: gif.url as! URL)
        savedGifs?.append(gif)
        print("Gif count \(savedGifs?.count)")
        NSKeyedArchiver.archiveRootObject(savedGifs!, toFile: gifsFilePath)
    }
    
    // MARK: CollectionView Delegate and DataSource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = savedGifs?.count {
            return count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        cell.configureForGif(gif: savedGifs![indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gif = savedGifs?[indexPath.item]
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.gif = gif
        detailVC.modalPresentationStyle = .overCurrentContext
        present(detailVC, animated: true, completion: nil)
    }
    
    // MARK: CollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - (cellMargin * 2)) / 2
        return CGSize(width: width, height: width)
    }
}

