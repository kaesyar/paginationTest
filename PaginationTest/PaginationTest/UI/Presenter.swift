//
//  Presenter.swift
//  PaginationTest
//
//  Created by Shakhzod Omonbayev on 23/09/23.
//

import Foundation
import DequeModule

enum PageLoadType: Equatable {
    case prev, next, initial, custom(elementNumber: Int)
}

final class Presenter {
    public var data  = Deque<Int>()
    
    private let pageSize = 20
    private var isLoading = false
    
    func loadData(page pageType: PageLoadType, completion:  @escaping (Int) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.25) {
            defer { self.isLoading = false }
            guard let newData = self.getData(for: pageType) else  { return }
            
            switch pageType {
            case .prev:
                self.data.prepend(contentsOf: newData)
            case .next:
                self.data.append(contentsOf: newData)
            case .initial, .custom(_):
                self.data = Deque(newData)
            }
            completion(newData.count)
        }
    }
    
    private func getData(for type: PageLoadType) -> [Int]? {
        //simulate network call or db call with caching
        switch type {
        case .prev:
            let lastElement = (self.data.first ?? -Int.max)
            let nextElement = lastElement + 1
            return Array((nextElement...nextElement + pageSize - 1).map { $0 }.reversed())
        
        case .next:
            guard let lastElement = self.data.last, lastElement > 1 else { return nil }
            
            let nextElement =  self.data.last! - 1
            return Array((nextElement - pageSize...nextElement).map { $0 }.reversed())
        
        case .initial:
            return Array((0..<pageSize).map { $0 }.reversed())
            
        case .custom(let element):
            return Array((element - pageSize / 2..<element + pageSize / 2).map { $0 }.reversed() )
        }
    }
}
