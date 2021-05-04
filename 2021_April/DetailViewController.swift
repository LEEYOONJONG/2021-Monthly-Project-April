//
//  DetailViewController.swift
//  2021_April
//
//  Created by YOONJONG on 2021/04/07.
//

import UIKit
import Firebase


protocol SendDataDelegate {
    func sendData(data: Double)
}

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate:SendDataDelegate?
    
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
        cell.subjectInput.text = subjects[indexPath.item]
        cell.pointInput.text = "\(points[indexPath.item])"
        cell.gradeInput.text = "\(grades[indexPath.item])"
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
    
    @IBAction func close(_ sender: Any) {
        
        print("close 실행")
        delegate?.sendData(data: calcGrades())
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
    }
}
extension DetailViewController{
    // 학점 계산
    func calcGrades() -> Double {
        var sumGrades:Double=0.0
        var sumPoints:Double=0.0
        for i in 0..<grades.count{
            if (grades[i] != 0){
                sumGrades += points[i]*grades[i]
                sumPoints += points[i]
            }
        }
        if sumGrades == 0 {
            return 0
        }
        return round(sumGrades / sumPoints * 1000) / 1000
    }
    
    
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
        
        // Firebase로부터 긁어오기
//        self.db.child("Students").child("Yoonjong Lee").setValue([""])
        self.db.child("Students").child("Yoonjong Lee").observeSingleEvent(of: .value) { snapshot in
            print("--> \(snapshot.value!)")
            
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value!, options: [])
                let decoder = JSONDecoder()
                
                self.student = try decoder.decode(Student.self, from: data)
                self.studentExist = true
                self.toArray()
                self.arrayToTextField()
                
            } catch let error { // 파베에 아무것도 없다면 학기 8개, 각 학기별 과목 8개 빈 배열 세팅한다.
                print("--> error : ", error.localizedDescription)
                var newSemesters:[Semester] = []
                let newSubjects:[Subject] = Array(repeating: Subject(title: "", point: 0, grade: 0), count: 8)

                for i in 0..<8 {
                    newSemesters.append(Semester(semesterNum: i, subjects: newSubjects, average: 0))
                }
                self.student = Student(name: "Yoonjong Lee", semesters: newSemesters )
            }
            
        }
        
    }
    
    // 데이터를 긁어오는데 성공했다면, 이를 배열에 넣어주자.
    func toArray(){
        if (self.studentExist == true){
            
            // 현재 student의 학기 목록에 대상 학기가 존재하는지
            var currentSemesterInFB:Bool = false
            for i in 0..<self.student!.semesters.count{
                if(semesterIndex == self.student!.semesters[i].semesterNum) {
                    currentSemesterInFB = true
                    for j in 0..<8 {
                        self.subjects[j] = self.student!.semesters[i].subjects[j].title
                        self.points[j] = self.student!.semesters[i].subjects[j].point
                        self.grades[j] = self.student!.semesters[i].subjects[j].grade
                    }
                }
            }
            if currentSemesterInFB == false {
                print("해당 학기에 데이터가 없다!")
            }
            
        }
        else {
            print("-> 긁어오지 못함")
        }
    }
    func arrayToTextField(){
        for i in 0..<8{
            self.DetailCollectionView.reloadItems(at: [IndexPath(item: i, section: 0)])
        }
    }
}
extension DetailViewController {
    func cellToDB(){
  
        var newSubjects:[Subject] = Array(repeating: Subject(title: "", point: 0, grade: 0), count: 8)
              
        // newSubject 구성
        for cell in DetailCollectionView.visibleCells as! [DetailCell]{
            let indexPath = DetailCollectionView.indexPath(for: cell)
            
            // -- 생략 가능
            subjects[indexPath!.item] = cell.subjectInput.text ?? ""
            points[indexPath!.item] = Double(cell.pointInput.text!) ?? 0
            grades[indexPath!.item] = Double(cell.gradeInput.text!) ?? 0
            
            // 각 semester의 subjects들을 newSubject에 데이터화.
            newSubjects[indexPath!.item] = Subject(title: cell.subjectInput.text ?? "", point: Double(cell.pointInput.text!) ?? 0, grade: Double(cell.gradeInput.text!) ?? 0)
        }
        
        self.student?.semesters[semesterIndex ?? 18] =
            Semester(semesterNum: semesterIndex!, subjects: newSubjects, average: calcGrades())
        let newStudent:Student = Student(name: "Yoonjong Lee", semesters: self.student!.semesters)
        db.child("Students").child(newStudent.name).setValue(newStudent.studentToDict)
        
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
    var average:Double
    var semesterToDict:[String:Any] {
        let subjectsArray = subjects.map{$0.subjectToDict}
        let semesterDict:[String:Any] = ["semesterNum":semesterNum, "subjects":subjectsArray, "average":average]
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
