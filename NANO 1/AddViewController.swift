//
//  AddViewController.swift
//  NANO 1
//
//  Created by Reza Mac on 27/04/22.
//

import UIKit
import CoreData

protocol AddViewControllerDelegate: AnyObject {
    func refreshTable()
}

class AddViewController: UIViewController {

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    
    @IBOutlet weak var dateField: UIDatePicker!
    weak var delegate: AddViewControllerDelegate?
    
    var data: [NSManagedObject] = []
    var pickerView = UIPickerView()
    
    var typeArr: [String] = ["income", "spending"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        typeTextField.inputView = pickerView
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height / 5 * 2, width: self.view.bounds.width, height: UIScreen.main.bounds.height / 5 * 3)
        self.view.layer.cornerRadius = 20
        self.view.layer.masksToBounds = true
            
    }

    @IBAction func cancelBtnPressed(_ sender: Any) {
        delegate?.refreshTable()

        dismiss(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        delegate?.refreshTable()

        updateBalance(amount: NumberFormatter().number(from: amountTextField.text!) as! Int)
        saveCashflow(amount: Int(amountTextField.text!)!, type: typeTextField.text!, item: itemTextField.text!, date: dateField.date)
        
    }
    func saveCashflow(amount: Int, type: String, item: String, date: Date){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
          }
          
        let managedContext =
        appDelegate.persistentContainer.viewContext

        let entity =
        NSEntityDescription.entity(forEntityName: "Cashflow",
                                   in: managedContext)!

        let object = NSManagedObject(entity: entity,
                                   insertInto: managedContext)

        object.setValue(amount, forKeyPath: "value")
        object.setValue(type, forKey: "type")
        object.setValue(item, forKey: "title")
        object.setValue(date, forKey: "date")
          
        do {
            try managedContext.save()
            data.append(object)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateBalance(amount: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Balance")
        let numberFormatter = NumberFormatter()
        
        numberFormatter.locale = Locale(identifier: "id_ID")
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as? [NSManagedObject]
            let objUpdate = result![0]
            let amountBefore = objUpdate.value(forKey: "value")
            var amountAfter: Int?
            if typeTextField.text == "income" {
                amountAfter = amountBefore as! Int + amount

            }
            else if typeTextField.text == "spending" {
                amountAfter = amountBefore as! Int - amount
            }

            objUpdate.setValue(NSNumber(value: amountAfter!), forKey: "value")
            print(objUpdate.value(forKey: "value")!)

            
        } catch {
            
            print("Failed")
        }
        
        do {
          try context.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeArr.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeArr[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = typeArr[row]
        typeTextField.resignFirstResponder()
    }
}
