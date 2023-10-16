//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    private var posts : [Post] = []
    let refreshControl = UIRefreshControl()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //gets a resuable cell so UI doesn't create new ones
        let cell =  tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        //getting post associated with table view row
        let post = posts[indexPath.row]
        
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            
            //use Nuke Helper method...
            Nuke.loadImage(with: url, into: cell.PostImageView)
        }
        
        cell.CaptionLabel.text = post.summary
        
        return cell
    }
    
    @objc func refreshData() {
       
        fetchPosts()
        
    }
    
    
    
    @IBOutlet weak var TableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        fetchPosts()
        
        TableView.dataSource = self
        
        //refresh control
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Loading new posts")
        TableView.addSubview(refreshControl)
        
        TableView.dataSource = self
    }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in
                    
                    let posts = blog.response.posts
                    self?.posts = posts
                    
                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    self?.TableView.reloadData()
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
