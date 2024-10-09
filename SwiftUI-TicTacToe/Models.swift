//
//  Models.swift
//  SwiftUI-TicTacToe
//
//  Created by Alexander Gerus on 11.04.2023.
//

import SwiftUI

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}
