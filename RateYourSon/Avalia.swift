//
//  ViewController.swift
//  RateYourSon
//
//  Created by Ettore Luglio on 29/04/17.
//  Copyright © 2017 Tamadrum. All rights reserved.
//

import Foundation
import UIKit

class Avalia: UIViewController, UITableViewDataSource, UITableViewDelegate, AtualizaAssunto {

    var avaliacoes: [Avaliacao] = []
    var data: String!
    var delegate: AtualizaTela!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = data
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AvaliacaoDao().save()
        
        delegate.atualizaTela()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "segueAssuntos" ) {
            let view = segue.destination as! Assuntos
            view.delegate = self
        }
    }

    // MARK: Coisas de Tabela
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return avaliacoes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula") as! ItemAvaliacao
        
        let avaliacao = avaliacoes[indexPath.row]
        
        cell.avaliacao = avaliacao
        cell.assunto.text = avaliacao.assunto
        
        if ( avaliacao.status == "feliz") { cell.status.selectedSegmentIndex = 0 }
        if ( avaliacao.status == "medio") { cell.status.selectedSegmentIndex = 1 }
        if ( avaliacao.status == "triste") { cell.status.selectedSegmentIndex = 2 }
        if ( avaliacao.status == "na") { cell.status.selectedSegmentIndex = 3 }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt heightForRowAtIndexPath:IndexPath) -> CGFloat{
        return 100
    }
    
    func adicionaAssunto(_ assunto: String) {
        let dao = AvaliacaoDao()
        
        let avaliacao:[Avaliacao] = avaliacoes.filter{$0.assunto == assunto}
        if ( avaliacao.count == 0 ) {
            print("Não existe, vou criar")
            let novoassuntoNaData = dao.new()
            novoassuntoNaData.assunto = assunto
            novoassuntoNaData.data = data
            novoassuntoNaData.status = "na"
            dao.save()
            
            avaliacoes.append(novoassuntoNaData)
            
            tableView.reloadData()
        } else {
            print("Já existe")
        }
    }
    
    func deleteAssunto(_ assunto: String) {
        let avaliacao:[Avaliacao] = avaliacoes.filter{$0.assunto == assunto}
        if ( avaliacao.count > 0 ) {
            let posicao = avaliacoes.index(of: avaliacao[0])
            avaliacoes.remove(at: posicao!)
            
            let dao = AvaliacaoDao()
            dao.removeAssuntoDaData(avaliacao[0])
            dao.save()
            
            tableView.reloadData()
        }
    }
    
    func updateTabela() {
        avaliacoes = AvaliacaoDao().listaAvaliacoesPorData(data)
        tableView.reloadData()
    }
    
}

