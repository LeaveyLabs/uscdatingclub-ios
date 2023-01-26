//
//  SimpleEntryCell.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/08.
//

import UIKit

class SimpleEntryCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = AppFont.light.size(16)
        textField.font = AppFont.semibold.size(20)
        self.selectionStyle = .none
    }
    
    func configure(title: String, content: String, delegate: UITextFieldDelegate) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.text = content
        textField.delegate = delegate
        titleLabel.text = title
        selectionStyle = .none
        textField.isSecureTextEntry = false
        self.selectionStyle = .none
    }
    
    func configureDropdown(title: String, content: String, textFieldDelegate: UITextFieldDelegate, pickerDelegate: UIPickerViewDelegate, pickerDataSource: UIPickerViewDataSource) {
        configure(title: title, content: content, delegate: textFieldDelegate)
        let sexPicker = UIPickerView(frame: .zero)
        sexPicker.delegate = pickerDelegate
        sexPicker.dataSource = pickerDataSource
        textField.inputView = sexPicker
    }
    
}
