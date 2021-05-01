//
//  ViewController.swift
//  2021_April
//
//  Created by YOONJONG on 2021/03/30.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var semesterList:[String] = ["1학년 1학기", "1학년 2학기", "2학년 1학기", "2학년 2학기", "3학년 1학기", "3학년 2학기", "4학년 1학기", "4학년 2학기"]
    var scoreList:[Double] = [0,0,0,0,0,0,0,0]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as? ScoreCell else { return UICollectionViewCell() }
        cell.semesterLabel.text = semesterList[indexPath.row]
        cell.scoreLabel.text = "\(scoreList[indexPath.row])"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ScoreCellHeaderView", for: indexPath)
            return headerView
        default:
            assert(false, "응 아니야") }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as? DetailViewController
            if let index = sender as? Int{
                vc?.semester = semesterList[index]
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: indexPath.row)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

class ScoreCell: UICollectionViewCell{
    @IBOutlet weak var semesterLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    
    
}

class ScoreCellHeaderView: UICollectionReusableView{
    
    @IBOutlet weak var headerLabel: UILabel!
}


