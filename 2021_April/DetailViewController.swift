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
    var semesterIndex:Int?
    
    var student:Student?
    var studentExist:Bool = false
    
    var subjects:[String]=["","","","","","","",""]
    var points:[Double]=[0,0,0,0,0,0,0,0]
    var grades:[Double]=[0,0,0,0,0,0,0,0]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as? DetailCell else { return UICollectionViewCell() }
//        cell.subjectInput.text = subjects[indexPath.item]
//        cell.pointInput.text = "\(points[indexPath.item])"
//        cell.gradeInput.text = "\(grades[indexPath.item])"
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
    
    func cellToDB(){
//        var isBlank:Bool
//        isBlank = fetchData() // 데이터가 있으면 true, 없으면 false
        
        
        
        var newSubjects:[Subject] = [Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0),Subject(title: "", point: 0, grade: 0)]
        
        // newSubject 구성
        var i=0
        for cell in DetailCollectionView.visibleCells as! [DetailCell]{
            let indexPath = DetailCollectionView.indexPath(for: cell)
            
            // -- 생략 가능
            subjects[indexPath!.item] = cell.subjectInput.text ?? ""
            points[indexPath!.item] = Double(cell.pointInput.text!) ?? 0
            grades[indexPath!.item] = Double(cell.gradeInput.text!) ?? 0
            
            // 각 semester의 subjects들을 newSubject에 데이터화.
            newSubjects[indexPath!.item] = Subject(title: cell.subjectInput.text ?? "", point: Double(cell.pointInput.text!) ?? 0, grade: Double(cell.gradeInput.text!) ?? 0)
            i += 1
        }
        
        
        // 무작정 0이 아니라, 1학년 1학기면 0, 1학년 2학기면 1, 이런 식으로 해야함
        var newSemesters:[Semester]=[]
        newSemesters.append(Semester(semesterNum: semesterIndex ?? -1, subjects: newSubjects))
        let newStudent:Student = Student(name: "Yoonjong Lee", semesters: newSemesters)
        db.child("Students").child(newStudent.name).setValue(newStudent.studentToDict)
        
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 파이어베이스의 데이터베이스를 뷰에 띄우기
        fetchData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        // 디테일 뷰가 사라질 때
        // 이때 firebase 디비에 저장해주어야
        
        cellToDB()
//        db.child("Students").removeValue()
        print(subjects)
        print(points)
        print(grades)
        
    }
}
extension DetailViewController{
    
    // Firebase DB로부터 "Yoonjong Lee"의 데이터를 긁어온다.
    func fetchData(){
        // 가장 먼저 current 학기에 할당된 semesterIndex를 초기화하자.
        if semester=="1학년 1학기" { semesterIndex = 0}
        else if semester=="1학년 2학기" { semesterIndex = 1}
        else if semester=="2학년 1학기" { semesterIndex = 2}
        else if semester=="2학년 2학기" { semesterIndex = 3}
        else if semester=="3학년 1학기" { semesterIndex = 4}
        else if semester=="3학년 2학기" { semesterIndex = 5}
        else if semester=="4학년 1학기" { semesterIndex = 6}
        else if semester=="4학년 2학기" { semesterIndex = 7}
        
        print("--> semester : \(semester), semesterIndex : \(semesterIndex)")
        
        // Firebase로부터 긁어오기
        self.db.child("Students").child("Yoonjong Lee").observeSingleEvent(of: .value) { snapshot in
            print("--> \(snapshot.value!)")
            print("- snapshot.childrenCount ->", snapshot.childrenCount)
            
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: [])
                let decoder = JSONDecoder()
                self.student = try decoder.decode(Student.self, from: data)
                self.studentExist = true
                print("self.student : \(self.student)")
                print("self.studentExist : \(self.studentExist)")
            } catch let error {
                print("-->error: \(error.localizedDescription)")
            }
            self.toArray()
        }
        
    }
    func toArray(){
        // 데이터를 긁어오는데 성공했다면, 이를 배열에 넣어주자.
        if (self.studentExist == true){
            print("-> 긁어오는데 성공, \(self.student)")
            print("-> semesters: \n", self.student!.semesters)
            
//            let subjectsCount = self.student!.semesters[semesterIndex ?? 0].subjects.count
//            for j in 0..<subjectsCount {
//                self.subjects[j] = self.student!.semesters[semesterIndex ?? 0].subjects[j].title
//                self.points[j] = self.student!.semesters[semesterIndex ?? 0].subjects[j].point
//                self.grades[j] = self.student!.semesters[semesterIndex ?? 0].subjects[j].grade
//            }
            
        }
        else {
            print("-> 긁어오지 못함")
        }
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

struct Student:Codable{
    let name:String
    var semesters:[Semester]
    
    var studentToDict:[String:Any] {
        let semesterDict = semesters.map{$0.semesterToDict}
        let studentDict:[String:Any] = ["name":name, "semesters":semesterDict]
        return studentDict
    }
}

struct Semester:Codable{
    let semesterNum:Int
    var subjects:[Subject]
    var semesterToDict:[String:Any] {
        let subjectsArray = subjects.map{$0.subjectToDict}
        let semesterDict:[String:Any] = ["semesterNum":semesterNum, "subjects":subjectsArray]
        return semesterDict
    }
    func sample(){
        print("help")
    }
}

struct Subject:Codable {
    var title:String
    var point:Double
    var grade:Double
    
    var subjectToDict:[String:Any]{
        let dict:[String:Any] = ["title":title, "point":point, "grade":grade]
        return dict
    }
}
