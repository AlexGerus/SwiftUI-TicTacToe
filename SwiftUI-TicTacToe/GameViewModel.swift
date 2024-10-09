//
//  GameViewModel.swift
//  SwiftUI-TicTacToe
//
//  Created by Alexander Gerus on 11.04.2023.
//

import SwiftUI

final class GameViewModel: ObservableObject {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    private let winPatterns: Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    private let centerSquare = 4
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisabled = false
    @Published var alertItem: AlertItem?
    
    func processPlayerMove(for position: Int) {
        
        // human move processing
        if isSquaredOccupied(in: moves, forIndex: position) {
            return
        }
        
        let moveResult = moveProcessing(for: .human, in: position)
        
        if (moveResult == 1) {
            return
        }
        
        // computer move processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let computerPosition = determineComputerMovePosition(in: moves)
            let moveResult = moveProcessing(for: .computer, in: computerPosition)
            
            if (moveResult == 1) {
                return
            }
        }
    }
    
    func moveProcessing(for player: Player, in position: Int) -> Int {
        moves[position] = Move(player: player,
                               boardIndex: position)
        isGameboardDisabled = player == .human
        // check for win condition or draw
        if checkWinCondition(for: player, in: moves) {
            switch player {
            case .human:
                alertItem = AlertContext.humanWin
            case .computer:
                alertItem = AlertContext.computerWin
            }
            return 1
        }
        
        if checkForDraw(in: moves) {
            alertItem = AlertContext.draw
            return 1
        }
        
        return -1
    }
    
    func isSquaredOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: { $0?.boardIndex == index })
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        
        // If AI can win, then win
        let nextPositionToWin = calculateNextStep(for: .computer)
        if (nextPositionToWin != -1) {
            return nextPositionToWin
        }
        
        // If AI can't win, then block
        let nextPositionToBlock = calculateNextStep(for: .human)
        if (nextPositionToBlock != -1) {
            return nextPositionToBlock
        }
        
        // If AI can't block, then take middle square
        if !isSquaredOccupied(in: moves, forIndex: centerSquare) {
            return centerSquare
        }
        
        // If AI can't take middle square, take random available square
        var movePosition = getRandomPosition()
        
        while isSquaredOccupied(in: moves, forIndex: movePosition) {
            movePosition = getRandomPosition()
        }
        
        return movePosition
    }
    
    func calculateNextStep(for player: Player) -> Int {
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(getPlayerPositions(for: player))
            
            if winPositions.count == 1 {
                let isAvailable = !isSquaredOccupied(in: moves, forIndex: winPositions.first!)
                if (isAvailable) { return winPositions.first! }
            }
        }
        return -1
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        for pattern in winPatterns where pattern.isSubset(of: getPlayerPositions(for: player)) {
            return true
        }
        
        return false
    }
    
    func getPlayerPositions(for player: Player) -> Set<Int> {
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        return Set(playerMoves.map { $0.boardIndex })
    }
    
    func getRandomPosition() -> Int {
        return Int.random(in: 0..<9)
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        isGameboardDisabled = false
    }
}
