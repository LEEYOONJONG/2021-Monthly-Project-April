//
//  DetailViewController.swift
//  2021_April
//
//  Created by YOONJONG on 2021/04/07.
//

import UIKit
import Firebase


class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var DetailCollectionView: UICollectionView!
    let db = Database.database().reference()
    var semester:String?
    
    var student:Student?
    
    var subjects:[String]=["","","","","","","",""]
    var points:[Double]=[0,0,0,0,0,0,0,0]
    var grades:[Double]=[0,0,0,0,0,0,0,0]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as? DetailCell else { return UICollectionViewCell() }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailCellHeaderView", for: indexPath) as! DetailCellHeaderView
            headerView.DetailHeaderLabel.text = semester
            return headerView
        default:
            assert(false, "응 아니야") }

        
    }
    func printall(){
        print(semester)
        var newSubject:[Subject]=[Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0)]
        
        var i=0
        for cell in DetailCollectionView.visibleCells as! [DetailCell]{
            
            let indexPath = DetailCollectionView.indexPath(for: cell)
            subjects[indexPath!.item] = cell.subjectInput.text ?? ""
            points[indexPath!.item] = Double(cell.pointInput.text!) ?? 0
            grades[indexPath!.item] = Double(cell.gradeInput.text!) ?? 0
            newSubject[indexPath!.item] = Subject(title: cell.subjectInput.text ?? "", point: Double(cell.pointInput.text!) ?? 0, grade: Double(cell.gradeInput.text!) ?? 0)
            i += 1
        }
        var newSemester:[Semester]=[]
        // 무작정 0이 아니라, 1학년 1학기면 0, 1학년 2학기면 1, 이런 식으로 해야함
        newSemester.append(Semester(semesterName: semester!, subjects: newSubject))
        let newStudent:Student = Student(name: "Yoonjong Lee", semesters: newSemester)
        db.child("Students").setValue(newStudent.studentToDict)
        
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        // 디테일 뷰가 사라질 때
        // 이때 firebase 디비에 저장해주어야
        
        printall()
//        db.child("Students").removeValue()
        print(subjects)
        print(points)
        print(grades)
        
    }
}

class DetailCell: UICollectionViewCell{
    
    @IBOutlet weak var subjectInput: UITextField!
    @IBOutlet weak var pointInput: UITextField!
    @IBOutlet weak var gradeInput: UITextField!
    
}

class DetailCellHeaderView: UICollectionReusableView{
    
    @IBOutlet weak var DetailHeaderLabel: UILabel!
    
}

struct Student{
    let name:String
    let semesters:[Semester]
    
    var studentToDict:[String:Any] {
        let semesterDict = semesters.map{$0.semesterToDict}
        let studentDict:[String:Any] = ["name":name, "semesters":semesterDict]
        return studentDict
    }
}

struct Semester{
    let semesterName:String
    var subjects:[Subject]
    var semesterToDict:[String:Any] {
        let subjectsArray = subjects.map{$0.subjectToDict}
        let semesterDict:[String:Any] = ["semesterName":semesterName, "subjects":subjectsArray]
        return semesterDict
    }
}

struct Subject {
    var title:String
    var point:Double
    var grade:Double
    
    var subjectToDict:[String:Any]{
        let dict:[String:Any] = ["title":title, "point":point, "grade":grade]
        return dict
    }
}
