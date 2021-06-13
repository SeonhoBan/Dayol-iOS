//
//  PaperListContentViewModel.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/02/02.
//

import RxSwift

class PaperListContentViewModel {
    typealias CellModel = PaperModalModel.PaperListCellModel
    enum PaperListevent {

        enum Action {
            case share
            case starred
            case copy
            case delete
        }

        case add
        case fetch
        case reorder(at: Int, to: Int)
        case activity(action: Action, at: Int)
    }

    var cellModels: [CellModel] {
        return DYTestData.shared.paperList.map {
            let paperType = $0.type
            let orientaion = Paper.PaperOrientation(rawValue: $0.orientation) ?? .portrait
            return CellModel(id: $0.id, isStarred: false, orientation: orientaion, paperType: paperType, thumbnailData: $0.thumbnail)
        }
    }

    var paperModels: [Paper] {
        DYTestData.shared.paperList
    }

    func moveItem(at sourceIndex: Int, to destinationIndex: Int) {
        DYTestData.shared.reorderPaper(from: sourceIndex, to: destinationIndex)
    }
}
