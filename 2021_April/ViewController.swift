//
//  ViewController.swift
//  2021_April
//
//  Created by YOONJONG on 2021/03/30.
//

// TODO LIST
// 1. ViewControoller에서 평균학점을 로컬에 저장하여 불러오는 기능
// 2. 처음 성적을 저장할 때, 메인화면으로 나오면 지연시간으로 인해 바로 업뎃 안됨(?)

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SendDataDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    // Delegate 위한 처리들
    var activatedScoreIndex:Int = 0
    func sendData(data: Double) {
        scoreList[activatedScoreIndex] = data
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as? DetailViewController
            if let index = sender as? Int{
                vc?.semester = semesterList[index]
                vc!.modalPresentationStyle = .fullScreen
                activatedScoreIndex = index
                vc?.delegate = self
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: indexPath.row)
        
    }
    
    

    override func viewDidLoad() {
        print("-- viewDidLoad 실행")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        print("-- viewWillAppear 실행")
//        print(scoreList)
        self.collectionView.reloadData()
        
    }

}

class ScoreCell: UICollectionViewCell{
    @IBOutlet weak var semesterLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    
    
}

class ScoreCellHeaderView: UICollectionReusableView{
    
    @IBOutlet weak var headerLabel: UILabel!
}


