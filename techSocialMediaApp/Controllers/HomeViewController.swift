//
//  HomeViewController.swift
//  techSocialMediaApp
//
//  Created by Wesley Keetch on 2/5/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!

  private var currentPage = 0
   private var isLoading = false
   private var hasMorePosts = true
   private var loadedPostIDs: Set<Int> = []

   var posts: [Post] = []

   private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Post> = {
     return UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView) {
       (collectionView, indexPath, post) -> UICollectionViewCell? in
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as? PostCell else {
         fatalError("Could not dequeue PostCell")
       }
       cell.configure(with: post)
       cell.onLikeTapped = { [weak self] in
         self?.toggleLike(for: post)
       }
       return cell
     }
   }()

   enum Section {
     case main
   }

   override func viewDidLoad() {
     super.viewDidLoad()

     setupCollectionView()
     setupFloatingButton()
     loadSamplePosts()
     fetchPosts()
     setupRefreshControl()
     collectionView.delegate = self
   }

   // MARK: - CollectionView Setup
   func setupCollectionView() {
     collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCell")

     let flowLayout = UICollectionViewFlowLayout()
     flowLayout.scrollDirection = .vertical
     flowLayout.itemSize = CGSize(width: view.frame.width - 24, height: 120)
     flowLayout.minimumInteritemSpacing = 8
     flowLayout.minimumLineSpacing = 12
     flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

     collectionView.setCollectionViewLayout(flowLayout, animated: false)
     collectionView.backgroundColor = .systemBackground

     updateDataSource()
   }

   // MARK: - Fetch Posts from API
   func fetchPosts() {
     guard !isLoading, hasMorePosts else { return }

     isLoading = true
     print("📡 Fetching posts from API (Page \(currentPage))...")

     Task {
       do {
         let fetchedPosts = try await PostService.shared.getPosts(pageNumber: currentPage)

         DispatchQueue.main.async {
           if fetchedPosts.isEmpty {
             self.hasMorePosts = false
             print("✅ No more posts available.")
           } else {
             let uniquePosts = fetchedPosts.filter { !self.loadedPostIDs.contains($0.postID) }
             self.loadedPostIDs.formUnion(uniquePosts.map { $0.postID }) // Track loaded posts

             if !uniquePosts.isEmpty {
               self.posts.append(contentsOf: uniquePosts)
               self.posts.sort { $0.createdDate > $1.createdDate }
               self.currentPage += 1
               self.updateDataSource()
             }
           }
           self.isLoading = false
         }
       } catch {
         print("❌ Failed to fetch posts: \(error.localizedDescription)")
         DispatchQueue.main.async {
           self.isLoading = false
         }
       }
     }
   }

   // MARK: - Update CollectionView with Diffable Data Source
   func updateDataSource() {
     print("updateDataSource() called with \(posts.count) posts")

     var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
     snapshot.appendSections([.main])
     snapshot.appendItems(posts)

     dataSource.apply(snapshot, animatingDifferences: true) {
       print("Snapshot Applied with \(self.posts.count) Posts")
     }
   }

   // MARK: - Load Sample Posts for Mock Data
   func loadSamplePosts() {
//     let samplePosts = [
//       Post(
//         postID: 1,
//         title: "Hello World",
//         body: "This is my first post!",
//         authorUserName: "User1",
//         authorUserId: UUID(),
//         likes: 10,
//         userLiked: false,
//         numComments: 5,
//         createdDate: "Date"()
//       ),
//       Post(
//         postID: 2,
//         title: "Swift is Awesome",
//         body: "Learning Swift and loving it!",
//         authorUserName: "Swiftie",
//         authorUserId: UUID(),
//         likes: 25,
//         userLiked: true,
//         numComments: 8,
//         createdDate: Date()
//       )
//     ]

//     self.posts = samplePosts
//     print("✅ Loaded Sample Posts: \(posts.count)")
//     self.updateDataSource()
   }

   // MARK: - Toggle Like on Post
   private func toggleLike(for post: Post) {
     Task {
       do {
         let updatedPost = try await PostService.shared.toggleLike(postID: post.postID, userLiked: !post.userLiked)
         DispatchQueue.main.async {
           if let index = self.posts.firstIndex(where: { $0.postID == post.postID }) {
             self.posts[index] = updatedPost
             self.updateDataSource()
           }
         }
       } catch {
         print("❌ Failed to update like: \(error.localizedDescription)")
       }
     }
   }

   // MARK: - Setup Floating Button
   private func setupFloatingButton() {
     let floatingButton = UIButton(type: .system)
     floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
     floatingButton.tintColor = .white
     floatingButton.backgroundColor = .brown
     floatingButton.layer.cornerRadius = 30
     floatingButton.clipsToBounds = true
     floatingButton.translatesAutoresizingMaskIntoConstraints = false
     floatingButton.addTarget(self, action: #selector(didTapCreatePost), for: .touchUpInside)

     view.addSubview(floatingButton)

     NSLayoutConstraint.activate([
       floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
       floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
       floatingButton.widthAnchor.constraint(equalToConstant: 60),
       floatingButton.heightAnchor.constraint(equalToConstant: 60)
     ])
   }

   func setupRefreshControl() {
     let refreshControl = UIRefreshControl()
     refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
     collectionView.refreshControl = refreshControl
   }

   @objc func didTapCreatePost() {
     let storyboard = UIStoryboard(name: "Main", bundle: nil)
     guard let createPostVC = storyboard.instantiateViewController(withIdentifier: "CreatePostViewController") as? CreatePostViewController else {
       print("❌ Failed to instantiate CreatePostViewController")
       return
     }

     if let sheet = createPostVC.sheetPresentationController {
       sheet.detents = [.large()]
       sheet.prefersGrabberVisible = true
       sheet.prefersScrollingExpandsWhenScrolledToEdge = false
     }

     present(createPostVC, animated: true, completion: nil)
   }

   @objc private func refreshPosts() {
     Task {
       do {
         currentPage = 0
         hasMorePosts = true
         loadedPostIDs.removeAll()
         let latestPosts = try await PostService.shared.getPosts()

         DispatchQueue.main.async {
           self.posts = latestPosts
           self.posts.sort { $0.createdDate > $1.createdDate }
           self.updateDataSource()
           self.collectionView.refreshControl?.endRefreshing()
         }
       } catch {
         print("❌ Failed to refresh posts: \(error.localizedDescription)")
         DispatchQueue.main.async {
           self.collectionView.refreshControl?.endRefreshing()
         }
       }
     }
   }
 }
