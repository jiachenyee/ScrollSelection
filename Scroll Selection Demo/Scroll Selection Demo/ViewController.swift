//
//  ViewController.swift
//  Scroll Selection Demo
//
//  Created by JiaChen(: on 15/9/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var scrollSelection: ScrollSelection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setting up Scoll Selection
        scrollSelection = createScrollSelection()
    }

    // Actions when clicking on buttons
    @IBAction func didClickTrash(_ sender: Any) {
        let alert = UIAlertController(title: "Tapped on trash", message: "Hey you tapped on trash!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didClickLasso(_ sender: Any) {
        let alert = UIAlertController(title: "Tapped on Lasso", message: "Hey you tapped on lasso!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didClickShare(_ sender: Any) {
        let alert = UIAlertController(title: "Tapped on Share", message: "Hey you tapped on share!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel!.text = ["This", "is", "a", "demo", "app"][indexPath.row % 5]
        cell.textLabel!.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize,
                                                           weight: .medium)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollSelection.didScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollSelection.didEndDragging()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollSelection.didEndDecelerating()
    }
}
