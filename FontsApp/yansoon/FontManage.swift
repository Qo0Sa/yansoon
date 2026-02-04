//
//
//  FontManage.swift
//  yansoon
//
//  Created by Noor Alhassani on 16/08/1447 AH.
//

import SwiftUI

struct AppFont {
    
    static func main(size: CGFloat) -> Font {
        let isArabic = Locale.current.language.languageCode?.identifier == "ar"
        return isArabic ? .custom("TheYearofHandicrafts-Bold", size: size) : .custom("TheYearofTheCamel-Bold", size: size)
    }
}
