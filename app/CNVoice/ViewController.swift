//
//  ViewController.swift
//  CNVoice
//
//  Created by qiwihui on 2/13/20.
//  Copyright © 2020 qiwihui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var originalText: UITextView!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var resultText: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    
    let SEPERATOR: Set<Character> = [" ", "，", "。", ",", ";", ",", "?", ".", "？", "；", "“", "”", "#","、", "【", "】", "《", "》", "[", "]", "\"", "'", "-", "-", "_", "\n", "\t"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.originalText.layer.borderColor = UIColor.gray.cgColor
        self.originalText.layer.borderWidth = 1
        self.originalText.layer.cornerRadius = 5
        
        self.resultText.layer.borderColor = UIColor.gray.cgColor
        self.resultText.layer.borderWidth = 1
        self.resultText.layer.cornerRadius = 5
        self.resultText.layer.backgroundColor = UIColor(red:238/255.0, green:238/255.0, blue:238/255.0, alpha:1).cgColor
        
        self.generateButton.layer.borderColor = UIColor.gray.cgColor
        self.generateButton.layer.borderWidth = 1
        
        self.copyButton.layer.borderColor = UIColor.gray.cgColor
        self.copyButton.layer.borderWidth = 1
    }

    @IBAction func generate(_ sender: UIButton){
        // Get current label text.
        let originalString = originalText.text
        resultText.text = sentencize(src_txt: originalString ?? "")
        // Make label size fit new text.
    }
    
    @IBAction func copyToPastBoard(_ sender: UIButton) {
        UIPasteboard.general.string = self.resultText.text
        let alertDisapperTimeInSeconds = 2.0
        let alert = UIAlertController(title: nil, message: "已复制到剪贴板！", preferredStyle: .actionSheet)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + alertDisapperTimeInSeconds) {
          alert.dismiss(animated: true)
        }
    }
    
    func sentencize(src_txt: String) -> String{
        var sentence = ""
        var reordered_txt: [String] = []
        for c in src_txt {
            if is_seperator(c: c) {
                reordered_txt += reorder(token_list: tokenize(src_txt: sentence))
                reordered_txt.append(String(c))
                sentence = ""
            } else {
                sentence += String(c)
            }
        }
        if sentence != "" {
            reordered_txt += reorder(token_list: tokenize(src_txt: sentence))
        }
        return reordered_txt.joined(separator: "")
    }
    
    func is_ascii(c: Character) -> Bool {
        return c.isASCII
    }
    
    func is_seperator(c: Character) -> Bool {
        return SEPERATOR.contains(c)
    }

    func reorder(token_list: [String]) -> [String] {
        let n_grams = [2, 3]
        var i = 0
        if token_list.count <= 3 {
            return token_list
        }

        var token_list_reordered = [token_list[0]]
        let middle_token_list = Array(token_list[1..<token_list.endIndex-1])

        while (i<middle_token_list.count) {
            let n_gram = n_grams.randomElement()!
            let j = min(i+n_gram, middle_token_list.count)
            var n_gram_list = Array(middle_token_list[i..<j])
            n_gram_list = n_gram_list.shuffled()
            token_list_reordered += n_gram_list
            i = j
        }
        token_list_reordered.append(token_list.last!)
        return token_list_reordered
    }
        
    func tokenize(src_txt: String) -> [String] {
        var token_list: [String] = []
        var token = ""
        for c in src_txt {
            if is_ascii(c: c){
                token.append(c)
            } else {
                if token != "" {
                    token_list.append(token)
                    token = ""
                }
                token_list.append(String(c))
            }
        }
        if token != ""{
            token_list.append(token)
        }
        return token_list
    }
}
