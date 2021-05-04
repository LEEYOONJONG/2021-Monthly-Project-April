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
import Firebase
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SendDataDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Database.database().reference()
    
    
    var semesterList:[String] = ["1학년 1학기", "1학년 2학기", "2학년 1학기", "2학년 2학기", "3학년 1학기", "3학년 2학기", "4학년 1학기", "4학년 2학기"]
    var scoreList:[Double] = [0,0,0,0,0,0,0,0]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as? ScoreCell else { return UICollectionViewCell() }
        cell.semesterLabel.text = semesterList[indexPath.row]
        cell.scoreLabel.text = "\(scoreList[indexPath.row])"
        cell.scoreLabel45.text = "\(round(scoreList[indexPath.row]*1.07*100)/100)"
        
        cell.layer.cornerRadius = 15
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
        
        
        self.db.child("Students").child("Yoonjong Lee").observeSingleEvent(of: .value) { snapshot in
            print("--> \(snapshot.value!)")
            
            do {
                if (snapshot.childrenCount == 0 ){ // 어쩔 수 없이 이렇게 처리하기로 하자. catch let error로 안 넘어가기 때문에
                    print("no child")
                    return
                }
                else{
                    print("children!! : ",snapshot.childrenCount)
                    
                    let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: [])
                    let decoder = JSONDecoder()
                    let student = try decoder.decode(Student.self, from: data)
                    print("--> student : ", student)
                    for i in 0..<self.scoreList.count{
                        self.scoreList[i] = student.semesters[i].average
                    }
                }
            }
            ///////////////////
            // catch let 문 작동 안함....
            catch let error{ // 파베에 아무것도 없다면 학기 8개, 각 학기별 과목 8개 빈 배열 세팅한다.
                print("--> ERROR occured(ViewController) ", error.localizedDescription)
            }
            /////////////////
            self.collectionView.reloadData()
        }
    }
    
}

class ScoreCell: UICollectionViewCell{
    @IBOutlet weak var semesterLabel:UILabel!
    @IBOutlet weak var scoreLabel:UILabel!
    @IBOutlet weak var scoreLabel45: UILabel!
    
}

class ScoreCellHeaderView: UICollectionReusableView{
    
    @IBOutlet weak var headerLabel: UILabel!
}


