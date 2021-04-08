//
//  DetailViewController.swift
//  2021_April
//
//  Created by YOONJONG on 2021/04/07.
//

import UIKit



class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var DetailCollectionView: UICollectionView!
    
    var semester:String?
    
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
        for cell in DetailCollectionView.visibleCells as! [DetailCell]{
            let indexPath = DetailCollectionView.indexPath(for: cell)
//            print(indexPath, cell.gradeInput.text ?? "", cell.pointInput.text ?? "", cell.subjectInput.text ?? "")
            subjects[indexPath!.item] = cell.subjectInput.text ?? ""
            points[indexPath!.item] = Double(cell.pointInput.text!) ?? 0
            grades[indexPath!.item] = Double(cell.gradeInput.text!) ?? 0
        }
    }
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillDisappear(_ animated: Bool) {
        printall()
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

