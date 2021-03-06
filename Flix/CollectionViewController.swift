//
//  CollectionViewController.swift
//  Flix
//
//  Created by Michael Hamlett on 6/22/17.
//  Copyright © 2017 Michael Hamlett. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies : [[String: Any]] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        
        
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine: CGFloat = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3/2)
        
        
        
        
        fetchMovies()

        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        if let posterPathString = movie["poster_path"] as? String {
            let baseURLString = "https://image.tmdb.org/t/p/w500"
            let posterURL = URL(string: baseURLString + posterPathString)!
            cell.posterImageView.af_setImage(withURL: posterURL)
            
        }
        
        return cell
    }
    
    
    func fetchMovies() {
        self.pleaseWait()
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a06d91c1c64b7b127defb0bec66fbfe4&language=en-US&page=1")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            //this will run when network request returns
            if let error = error {
                let alertController = UIAlertController(title: "Network Error", message: "Cannot retrieve movie data", preferredStyle: .alert)
                // create a cancel action
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    // handle cancel response here. Doing nothing will dismiss the view.
                }
                // add the cancel action to the alertController
                alertController.addAction(cancelAction)
                
                self.clearAllNotice()
                self.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
                
                print(error.localizedDescription)
            }
            else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.collectionView.reloadData()
                //self.refreshControl.endRefreshing()
                self.clearAllNotice()
            }
        }
        task.resume()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell){
            let movie = movies[indexPath.row]
            let detail2ViewController = segue.destination as! Detail2ViewController
            detail2ViewController.movie = movie
        }
        
        
        
    }


}
