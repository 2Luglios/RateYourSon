//
//  ListaDias.swift
//  RateYourSon
//
//  Created by Ettore Luglio on 29/04/17.
//  Copyright © 2017 Tamadrum. All rights reserved.
//

import Foundation
import UIKit

class ListaDias: UIViewController, UITableViewDataSource, UITableViewDelegate, AtualizaTela {
    
    @IBOutlet weak var tableView: UITableView!

    var datas: [String] = []
    
    override func viewDidLoad() {
        datas = AvaliacaoDao().mostrarDatasDiferentes()
        tableView.reloadData()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(exibirMaisAcoes(gesture:)))
        self.tableView.addGestureRecognizer(gesture)
    }
    
    func exibirMaisAcoes(gesture:UIGestureRecognizer){
        if gesture.state == .began {
            let ponto = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at:ponto) {
                let dataSelecionada = datas[indexPath.row]
                
                let alerta = UIAlertController(title: "Alteração", message: "Arrume a data nova:", preferredStyle: .alert)
                
                alerta.addTextField(configurationHandler: {
                    (textField: UITextField!) in
                    textField.text = dataSelecionada
                })
                
                alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                
                alerta.addAction(UIAlertAction(title: "Salvar", style: .default, handler: {
                    (UIAlertAction) in
                    
                    let novaData = alerta.textFields?[0].text!
                    let dao = AvaliacaoDao()
                    let lista = dao.listaAvaliacoesPorData(dataSelecionada)
                    
                    for a in lista {
                        a.data = novaData
                    }
                    dao.save()
                    
                    self.datas = dao.mostrarDatasDiferentes()
                    self.atualizaTela()
                    
                }))
                
                if let nav = navigationController {
                    nav.present(alerta, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    // MARK: Coisas de Tabela
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula")
        cell?.imageView!.image = AvaliacaoDao().calculaMedia(datas[indexPath.row])
        cell?.textLabel!.text = datas[indexPath.row]
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let view = segue.destination as! Avalia
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        
        view.delegate = self
        view.data = datas[indexPath.row]
        view.avaliacoes = AvaliacaoDao().listaAvaliacoesPorData(datas[indexPath.row])
    }
    
    @IBAction func addData(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Adicionar Data:", message: "Digite a data a adicionar na lista.", preferredStyle: .alert)
        
        alerta.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Digite a data:"
        })
    
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alerta.addAction(UIAlertAction(title: "Salvar", style: .default, handler: {
            (UIAlertAction) in
            
            let dao = AvaliacaoDao()
            dao.adicionarAvaliacaoComData((alerta.textFields?[0].text)!)
            self.datas = dao.mostrarDatasDiferentes()
            self.atualizaTela()
        }))
        
        if let nav = navigationController {
            nav.present(alerta, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dao = AvaliacaoDao()
            dao.removerTudoDaData(datas[indexPath.row])
            dao.save()
            self.datas = dao.mostrarDatasDiferentes()
            atualizaTela()
        }
    }
    
    func atualizaTela() {
        tableView.reloadData()
    }
    
}
