//
//  ShareViewController.swift
//  Sharing Extension
//
import receive_sharing_intent

class ShareViewController: RSIShareViewController {
    
    // Use this method to return false if you don't want to redirect to host app automatically.
    // Default is true
//    override func shouldAutoRedirect() -> Bool {
//        return false
//    }
    
    // Use this to change label of Post button
    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Send"
    }
}
