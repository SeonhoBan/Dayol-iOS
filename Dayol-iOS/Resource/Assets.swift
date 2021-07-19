//
//  Assets.swift
//  Dayol-iOS
//
//  Created by Sungmin on 2020/12/09.
//

import UIKit

// TODO: - 애셋 뎁스가 깊어져서, 한번 정리하는 것도 좋을 것 같습니다.
enum Assets {
    enum Image {
        enum Home {
            static let topIcon = UIImage(named: "home_top_icon")
            static let emptyDiaryIcon = UIImage(named: "home_empty_diary")
            static let emptyFavoriteIcon = UIImage(named: "home_empty_favorite")
            static let emptyArrow = UIImage(named: "home_empty_arrow")
            static let plusButton = UIImage(named: "home_tabbar_plusbutton")
            static let diaryListActionButton = UIImage(named: "home_diaryList_dropdown")

            enum TabBarDiary {
                static let normal = UIImage(named: "home_tabbar_diary_normal")
                static let selected = UIImage(named: "home_tabbar_diary_selected")
            }

            enum TabBarFavorite {
                static let normal = UIImage(named: "home_tabbar_favorite_normal")
                static let selected = UIImage(named: "home_tabbar_favorite_selected")
            }
        }

        enum Settings {
            static let chevron = UIImage(named: "settings_chevron")
            static let detail = UIImage(named: "settings_inapp_deleted_detail")

            enum Backup {
                static let info = UIImage(named: "settings_backup_info")
                static let next = UIImage(named: "settings_backup_next")
            }
        }

        enum PaperAdd {
            enum Button {
                static let on = UIImage(named: "paper_add_btn_on")
                static let off = UIImage(named: "paper_add_btn_off")
            }
        }

        enum PaperList {
            static let chevronDown = UIImage(named: "paper_list_chevron_down")
            static let addCell = UIImage(named: "paper_list_cell_add_paper")
            static let starred = UIImage(named: "paper_list_cell_starred")
        }

        enum InfoView {
            static let info = UIImage(named: "InfoView_Icon_Info")
            static let close = UIImage(named: "InfoView_Icon_Close")
        }

        enum DiaryCover {
            static let lock = UIImage(named: "diaryCoverLock")
        }

        enum DYTextField {
            static let delete = UIImage(named: "textField_delete")
            enum Font {
                static let selected = UIImage(named: "font_selected")
                static let deselected = UIImage(named: "font_deselected")
            }
            enum CheckBox {
                static let on = UIImage(named: "textField_checkbox_on")
                static let off = UIImage(named: "textField_checkbox_off")
            }
        }

        enum ToolBar {
            static let info = UIImage(named: "toolBar_info")

            enum ColorPicker {
                static let whitePlus = UIImage(named: "toolBar_color_plus_white")
                static let blackPlus = UIImage(named: "toolBar_color_plus_black")
                static let whiteMinus = UIImage(named: "toolBar_color_minus_white")
                static let blackMinus = UIImage(named: "toolBar_color_minus_black")
            }

            enum TextStyle {
                static let plusButton = UIImage(named: "toolBar_textStyle_plus")
                static let minusButton = UIImage(named: "toolBar_textStyle_minus")
            }
        }

        enum Modal {
            static let down = UIImage(named: "btnModaldown")
        }
    }
}
