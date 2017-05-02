//
//  Assuntos.swift
//  RateYourSon
//
//  Created by Ettore Luglio on 01/05/17.
//  Copyright © 2017 Tamadrum. All rights reserved.
//

import Foundation
import UIKit

class Assuntos: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: AtualizaAssunto!
    
    var assuntos:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        assuntos = AvaliacaoDao().pegarAssuntos()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(exibirMaisAcoes(gesture:)))
        self.tableView.addGestureRecognizer(gesture)
    }
    
    func exibirMaisAcoes(gesture:UIGestureRecognizer){
        if gesture.state == .began {
            let ponto = gesture.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at:ponto) {
                let assuntoSelecionado = assuntos[indexPath.row]
                
                let alerta = UIAlertController(title: "Alteração", message: "Arrume o nome do assunto:", preferredStyle: .alert)
                
                alerta.addTextField(configurationHandler: {
                    (textField: UITextField!) in
                    textField.text = assuntoSelecionado
                })
                
                alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
                
                alerta.addAction(UIAlertAction(title: "Salvar", style: .default, handler: {
                    (UIAlertAction) in
                    
                    let novoAssunto = alerta.textFields?[0].text!
                    let dao = AvaliacaoDao()
                    let lista = dao.listaTudoComAssunto(assuntoSelecionado)
                    
                    for a in lista {
                        a.assunto = novoAssunto
                    }
                    dao.save()
                    
                    let posicao = self.assuntos.index(of: assuntoSelecionado)
                    self.assuntos[posicao!] = novoAssunto!
                    
                    self.tableView.reloadData()
                    self.delegate.updateTabela()
                    
                }))
                
                if let nav = navigationController {
                    nav.present(alerta, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AvaliacaoDao().salvarAssuntos(assuntos)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assuntos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula")
        
        cell?.textLabel?.text = assuntos[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delegate.deleteAssunto(assuntos[indexPath.row])
            
            assuntos.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    @IBAction func addAssunto(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Adicionar Assunto:", message: "Digite o assunto para adiciona na lista.", preferredStyle: .alert)
        
        alerta.addTextField(configurationHandler: {
            (textField: UITextField!) in
            textField.placeholder = "Digite o assunto:"
        })
        
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alerta.addAction(UIAlertAction(title: "Salvar", style: .default, handler: {
            (UIAlertAction) in
            
            self.assuntos.append((alerta.textFields?[0].text)!)
            
            self.delegate.adicionaAssunto((alerta.textFields?[0].text)!)
            
            self.tableView.reloadData()
        }))
        
        if let nav = navigationController {
            nav.present(alerta, animated: true, completion: nil)
        }
    }
    
}
