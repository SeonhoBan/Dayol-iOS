//
//  DYDrawTool.swift
//  Dayol-iOS
//
//  Created by 주성민 on 2021/04/28.
//

import PencilKit

private enum Design {
    static let defaultPenWidth: CGFloat = PencilSettingDetailView.Step.step3Width
}

// 기본적으로 드로잉 씬에서 사용하는 툴을 위한 프로토콜
protocol DYCanvasTool {
    var pkTool: PKTool { get }
}

// 색상, 넓이 설정이 적용되는 툴을 위한 세부 프로토콜
protocol DYDrawTool: DYCanvasTool {
    var color: UIColor { get set }
    var width: CGFloat { get set }
    var alpha: CGFloat { get set }
}

struct DYPenTool: DYDrawTool {
    var color: UIColor
    var width: CGFloat
    var alpha: CGFloat

    var pkTool: PKTool {
        if #available(iOS 14.0, *) {
            let ink = PKInk(.pen, color: color.withAlphaComponent(alpha))
            return PKInkingTool(ink: ink, width: width)
        } else {
            return PKInkingTool(.pen, color: color.withAlphaComponent(alpha), width: width)
        }
    }

}

struct DYMarkerTool: DYDrawTool {
    var color: UIColor
    var width: CGFloat
    var alpha: CGFloat

    var pkTool: PKTool {
        if #available(iOS 14.0, *) {
            let ink = PKInk(.marker, color: color.withAlphaComponent(alpha))
            return PKInkingTool(ink: ink, width: width)
        } else {
            return PKInkingTool(.marker, color: color.withAlphaComponent(alpha), width: width)
        }
    }

}

struct DYPencilTool: DYDrawTool {
    var color: UIColor
    var width: CGFloat
    var alpha: CGFloat

    var pkTool: PKTool {
        if #available(iOS 14.0, *) {
            let ink = PKInk(.pencil, color: color.withAlphaComponent(alpha))
            return PKInkingTool(ink: ink, width: width)
        } else {
            return PKInkingTool(.pencil, color: color.withAlphaComponent(alpha), width: width)
        }
    }

}

struct DYEraseTool: DYCanvasTool {
    var isObjectErase: Bool

    var pkTool: PKTool {
        let eraseType: PKEraserTool.EraserType = isObjectErase ? .vector : .bitmap
        return PKEraserTool(eraseType)
    }

    init(isObjectErase: Bool) {
        self.isObjectErase = isObjectErase
    }
}

struct DYLassoTool: DYCanvasTool {
    var pkTool: PKTool {
        return PKLassoTool()
    }
}

struct DYPKTools {
    enum ToolType {
        case pen, marker, pencil, erase, lasso
    }
    private var selectedType: ToolType = .pen
    var pen = DYPenTool(color: .black, width: Design.defaultPenWidth, alpha: 1)
    var marker = DYMarkerTool(color: .black, width: Design.defaultPenWidth, alpha: 1)
    var pencil = DYPencilTool(color: .black, width: Design.defaultPenWidth, alpha: 1)
    var erase = DYEraseTool(isObjectErase: false)
    let lasso = DYLassoTool()

    var selectedTool: DYCanvasTool {
        switch selectedType {
        case .pen: return pen
        case .marker: return marker
        case .pencil: return pencil
        case .erase: return erase
        case .lasso: return lasso
        }
    }

    mutating func select(toolType: ToolType) {
        selectedType = toolType
    }

    mutating func updateSelectedTool(color: UIColor) {
        switch selectedType {
        case .pen:
            pen.color = color
        case .marker:
            marker.color = color
        case .pencil:
            pencil.color = color
        default: return
        }
    }
}
