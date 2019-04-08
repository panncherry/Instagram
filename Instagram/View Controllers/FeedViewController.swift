//
//  FeedViewController.swift
//  Instagram
//
//  Created by Pann Cherry on 3/20/19.
//  Copyright © 2019 TechBloomer. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let commentBar = MessageInputBar()
    var showCommentBar = false
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    /*:
     # Hide Keyboard
     * When there is no input in comment bar, hide the keyboard
     */
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }
    
    
    /*:
     # Comment Bar
     * Initiate MessageInputBar
     */
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    
    /*:
     # Set FirstResponder
     * showCommentBar will be false
     */
    override var canBecomeFirstResponder: Bool {
        return showCommentBar
    }
    
    
    /*:
     # POST Comments
     * Create comment and save the comments in background
     */
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // Create comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        // Add comment to the selected post only
        selectedPost.add(comment, forKey: "comments")
        
        // Save the comment in Parse server
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved.")
            } else {
                print("Error saving comment.")
            }
        }
        
        // Reload table to show the comment just posted
        tableView.reloadData()
        
        // Clear comment field
        commentBar.inputTextView.text = nil
        
        // Set showCommentBar to false
        showCommentBar = false
        
        // Dimiss the keyboard
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    
    /*:
     # Display Comments
     * Display the posts and the comments if there is any
     * Post limit 20
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            } else {
                
            }
        }
    }
    
    
    /*:
     # Create Comment
     * Call this func when user tap on the post and allow user to comment
     * By showing MessageInputBar
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject] ?? [])
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
    }
    
    
    /*:
     # Table View - Number of Sections
     * retrun the total number of posts
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    
    /*:
     # Table View - Number of Rows in Section
     * return total number of comments for each post including the post itself
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject] ?? [])
        return comments.count + 2
    }
    
    
    /*:
     # Table View CellForRowAt
     * Create comment and save the comments in background
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject] ?? [])
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            cell.descriptionLabel.text = post["caption"] as? String
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af_setImage(withURL: url)
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    
    /*:
     # Log Out
     * Log out the current user
     * Display the rootViewController which is LogInViewController after successfully logged out
     */
    @IBAction func onClick_LogOutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let LogInViewController = main.instantiateViewController(withIdentifier: "LogInViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = LogInViewController
    }
    
    
    
}
