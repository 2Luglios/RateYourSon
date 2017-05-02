//
//  AvaliacaoDao.swift
//  RateYourSon
//
//  Created by Ettore Luglio on 29/04/17.
//  Copyright © 2017 Tamadrum. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AvaliacaoDao {
    
    let tabela = "Avaliacao"
    let contexto: NSManagedObjectContext!
    
    init() {
        let app = UIApplication.shared.delegate as? AppDelegate
        contexto = app?.persistentContainer.viewContext
        
        carregaDadosIniciais()
    }
    
    func carregaDadosIniciais() {
        let defaults = UserDefaults.standard
        
        let iniciais = ["Acordar", "Café da Manhã", "Almoço",
                        "Jantar", "Liçao de Casa", "Hora do Banho",
                        "Hora de Dormir", "Arrumar o Quarto", "Arrumar a Sala",
                        "Arrumar o Quarto de Brinquedo", "iPad"]
        
        if !defaults.bool(forKey: "primeiraVez") {
            defaults.set(iniciais.count, forKey: "qtd")
            for i in 0..<iniciais.count {
                defaults.set(iniciais[i], forKey: "assunto\(i)")
            }
            defaults.set(true, forKey: "primeiraVez")
        }
    }
    
    func new() -> Avaliacao {
        return NSEntityDescription.insertNewObject(forEntityName: tabela, into: contexto) as! Avaliacao
    }
    
    func save () {
        if contexto.hasChanges {
            do {
                try contexto.save()
            } catch {
                
            }
        }
    }
    
    func listaAvaliacoesPorData (_ data: String) -> [Avaliacao] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tabela)
        fetchRequest.predicate = NSPredicate(format: "data == %@", data)
        
        do {
            return try contexto.fetch(fetchRequest) as! [Avaliacao]
        } catch {
            return []
        }
    }
    
    func mostrarDatasDiferentes () -> [String] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tabela)
        fetchRequest.propertiesToFetch = ["data"]
        fetchRequest.returnsDistinctResults = true
        fetchRequest.resultType = .dictionaryResultType
        
        let results = try? contexto.fetch(fetchRequest)
        var stringResultsArray: [String] = []
        
        if let results = results {
            
            for i in 0..<results.count {
                if let dic = (results[i] as? [String : String]){
                    if let yearString = dic["data"]{
                        stringResultsArray.append(yearString)
                    }
                }
            }
        }
        return stringResultsArray
    }
    
    func listaTudoComAssunto (_ assunto: String) -> [Avaliacao]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tabela)
        fetchRequest.predicate = NSPredicate(format: "assunto == %@", assunto)
        
        do {
            return try contexto.fetch(fetchRequest) as! [Avaliacao]
        } catch {
            return []
        }
    }
    
    func calculaMedia(_ data: String) -> UIImage {
        let avaliacoes = listaAvaliacoesPorData(data)
        
        var qtd:[Int] = [0, 0, 0, 0]
//        var qtdFeliz = 0
//        var qtdTriste = 0
//        var qtdMedio = 0
//        var qtdNA = 0
        
        for a in avaliacoes {
            if ( a.status == "na" )     { qtd[0]+=1 }
            if ( a.status == "triste" ) { qtd[1]+=1 }
            if ( a.status == "feliz" )  { qtd[2]+=1 }
            if ( a.status == "medio" )  { qtd[3]+=1 }
        }
        
        let posicao = qtd.index(of: qtd.max()!)
        
        switch (posicao!) {
        case 2: return #imageLiteral(resourceName: "feliz")
        case 3: return #imageLiteral(resourceName: "medio")
        case 1: return #imageLiteral(resourceName: "triste")
        case 0: return #imageLiteral(resourceName: "na")
        default: return #imageLiteral(resourceName: "na")
        }
        
    }
    
    func adicionarAvaliacaoComData (_ data: String) {
        let assuntos = pegarAssuntos()
        for i in 0..<assuntos.count {
            let avaliacao = new()
            avaliacao.data = data
            avaliacao.assunto = assuntos[i]
            avaliacao.status = "feliz"
            save()
        }
    }
    
    func removerTudoDaData(_ data: String) {
        let avaliacoes = listaAvaliacoesPorData(data)
        for a in avaliacoes {
            contexto.delete(a)
        }
    }
    
    func removeAssuntoDaData(_ avaliacao: Avaliacao) {
        contexto.delete(avaliacao)
    }
    
    func salvarAssuntos(_ strings: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(strings.count, forKey: "qtd")
        for i in 0..<strings.count {
            defaults.set(strings[i], forKey: "assunto\(i)")
        }
    }
    
    func pegarAssuntos() -> [String]{
        var strings:[String] = []
        let defaults = UserDefaults.standard
        
        let qtd = defaults.integer(forKey: "qtd")
        for i in 0..<qtd {
            if let string = defaults.string(forKey: "assunto\(i)") {
                strings.append(string)
            }
        }
        return strings
    }
}

