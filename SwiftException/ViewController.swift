//
//  ViewController.swift
//  SwiftRuntimeException
//
//  Created by Mitsuhau Emoto on 2019/01/19.
//  Copyright © 2019 Mitsuhau Emoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tableView: ExcTableView!
    var counter: Int = 0
    var alert: UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "デモ"
        self.addTableView()
    }
    
    func addTableView(){
        
        self.removeTableView()
        
        self.tableView = ExcTableView(frame: self.view.bounds,
                                      style: UITableView.Style.plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "VanillaCell", bundle: nil),
                                forCellReuseIdentifier: "VanillaCell")
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor(white: 0.99, alpha: 1.0)
        self.view.addSubview(self.tableView)
    }
    
    func removeTableView()  {
        guard
            let tableView = self.tableView,
            let _ = self.tableView.superview else {
            return
        }
        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.removeFromSuperview()
    }
}

extension ViewController{
    
    // 配列の範囲外の要素にアクセスする
    func demo1(){
        ExcBlock.execute({
            let temps = [0, 1, 2]
            let _ = temps[10]
        }) { (exception) in
            self.alert = {
                let alert = UIAlertController(title: "exception",
                                              message: exception.description,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: UIAlertAction.Style.default,
                                              handler:nil))
                self.present(alert, animated: true, completion: nil)
                return alert
            }()
        }
    }
    
    // TableViewの範囲外のセルを更新する
    func demo2(){
        self.counter += 1
        let indexPath = IndexPath(row: 100, section: 100)
        self.tableView.exc_reloadRows(at: [indexPath], with: .automatic) { (exception) in
            self.alert = {
                let alert = UIAlertController(title: "exception",
                                              message: exception.description,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "fix",
                                              style: UIAlertAction.Style.default,
                                              handler: { (action) in
                                                self.addTableView()
                }))
                self.present(alert, animated: true, completion: nil)
                return alert
            }()
        }
    }
    
    // 配列の範囲外の要素にアクセスする
    func demoFortify(){
        do {
            // Edit Scheme から debug excutable を無効にする
            try Fortify.exec {
                let temps = [0, 1, 2]
                let _ = temps[10]
            }
        }
        catch {
            self.alert = {
                let alert = UIAlertController(title: "exception",
                                              message: error.localizedDescription,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: UIAlertAction.Style.default,
                                              handler:nil))
                self.present(alert, animated: true, completion: nil)
                return alert
            }()
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var str = "デモ \(section + 1)"
        if section == 2{
            str = "おまけ"
        }
        return str
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VanillaCell",
                                                 for: indexPath)
        let sec = indexPath.section
        var str: String = ""
        var sub: String? = nil
        if sec == 0{
            str = "配列の範囲外の要素にアクセスする"
        }else if sec == 1{
            str = "範囲外のセルを更新する (tap:\(self.counter))"
        }else{
            str = "配列の範囲外の要素にアクセスする(Fortify)"
            sub = "Edit Scheme から debug excutable を無効にする"
        }
        cell.textLabel?.text = str
        cell.detailTextLabel?.text = sub
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sec = indexPath.section
        if sec == 0{
            self.demo1()
        }else if sec == 1{
            self.demo2()
        }else{
            self.demoFortify()
        }
    }
    
}

