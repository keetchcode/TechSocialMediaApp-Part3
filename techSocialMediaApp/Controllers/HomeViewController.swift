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

  private var dataSource: UICollectionViewDiffableDataSource<Section, Post>!

  private let cactusLoader = CactusLoader()

  enum Section {
    case main
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupCollectionView()
    setupFloatingButton()
    setupRefreshControl()
    setupCactusLoader()
    fetchAllPosts()
  }

  // MARK: - CollectionView Setup
  func setupCollectionView() {
    collectionView.delegate = self
    collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCell")

    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.itemSize = CGSize(width: view.frame.width - 24, height: 120)
    flowLayout.minimumInteritemSpacing = 8
    flowLayout.minimumLineSpacing = 12
    flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)

    collectionView.setCollectionViewLayout(flowLayout, animated: false)
    collectionView.backgroundColor = .systemBackground

    dataSource = UICollectionViewDiffableDataSource<Section, Post>(collectionView: collectionView) {
      (collectionView, indexPath, post) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as? PostCell else {
        fatalError("❌ Could not dequeue PostCell")
      }
      cell.configure(with: post)

      cell.onLikeTapped = { [weak self] in
        self?.toggleLike(for: post)
      }

      // ✅ Add Comment Tap Handling
      cell.onCommentTapped = { [weak self] in
        self?.presentCommentModal(for: post)
      }

      return cell
    }

    updateDataSource()
  }

  private func setupCactusLoader() {
    cactusLoader.translatesAutoresizingMaskIntoConstraints = false
    cactusLoader.isHidden = false // ✅ Ensure it's visible
    view.addSubview(cactusLoader)

    // ✅ Bring it to the front so it overlays everything
    view.bringSubviewToFront(cactusLoader)

    NSLayoutConstraint.activate([
      cactusLoader.widthAnchor.constraint(equalToConstant: 60),
      cactusLoader.heightAnchor.constraint(equalToConstant: 70),
      cactusLoader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      cactusLoader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  func fetchAllPosts() {
      guard !isLoading, hasMorePosts else { return }

      isLoading = true
      DispatchQueue.main.async {
          self.cactusLoader.startAnimating() // ✅ Force UI update
      }

      Task {
          var allPosts: [Post] = []
          var page = 0

          while hasMorePosts {
              do {
                  let fetchedPosts = try await PostService.shared.getPosts(pageNumber: page)
                  DispatchQueue.main.async {
                      if fetchedPosts.isEmpty {
                          self.hasMorePosts = false
                      } else {
                          let uniquePosts = fetchedPosts.filter { !self.loadedPostIDs.contains($0.postID) }
                          self.loadedPostIDs.formUnion(uniquePosts.map { $0.postID })

                          if !uniquePosts.isEmpty {
                              allPosts.append(contentsOf: uniquePosts)
                              page += 1
                          }
                      }
                  }
              } catch {
                  print("❌ Failed to fetch posts: \(error.localizedDescription)")
                  DispatchQueue.main.async {
                      self.isLoading = false
                      self.cactusLoader.stopAnimating() // ✅ Stop animation on error
                  }
                  break
              }
          }

          DispatchQueue.main.async {
              self.posts = allPosts
              self.posts.sort { $0.createdDate > $1.createdDate }
              self.updateDataSource()
              self.isLoading = false
              self.cactusLoader.stopAnimating() // ✅ Stop animation when posts are loaded
          }
      }
  }
  // MARK: - ✅ Detect Scrolling Near Bottom (Fetch More If Needed)
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let frameHeight = scrollView.frame.size.height

    if offsetY > contentHeight - frameHeight * 2 {
      fetchAllPosts() // ✅ Keep loading until all posts are fetched
    }
  }

  // MARK: - ✅ Update CollectionView with Diffable Data Source
  func updateDataSource() {
    print("updateDataSource() called with \(posts.count) posts")

    var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
    snapshot.appendSections([.main])
    snapshot.appendItems(posts)

    dataSource.apply(snapshot, animatingDifferences: true) {
      print("✅ Snapshot Applied with \(self.posts.count) Posts")
    }
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

  // MARK: - Handle Navigation to PostDetailViewController
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let post = dataSource.itemIdentifier(for: indexPath) else { return }
    navigateToPostDetail(with: post)
  }

  private func navigateToPostDetail(with post: Post) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let postDetailVC = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as? PostDetailViewController else {
      print("❌ Failed to instantiate PostDetailViewController")
      return
    }

    postDetailVC.post = post
    navigationController?.pushViewController(postDetailVC, animated: true)
  }

  private func presentCommentModal(for post: Post) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as? CommentsViewController else {
      print("❌ Failed to instantiate CommentsViewController")
      return
    }

    commentVC.postID = post.postID // ✅ Pass the post ID for fetching and posting comments
    commentVC.modalPresentationStyle = .pageSheet // ✅ Make it a sheet (iOS 15+)

    if let sheet = commentVC.sheetPresentationController {
      sheet.detents = [.medium(), .large()] // ✅ Allows resizing
      sheet.prefersGrabberVisible = true
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }

    present(commentVC, animated: true)
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

  // MARK: - Setup Refresh Control
  func setupRefreshControl() {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
    collectionView.refreshControl = refreshControl
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
