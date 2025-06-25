//
//  Game1view.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 20/6/25.
//

import SwiftUI

// MARK: - Models

struct Point: Hashable, Equatable {
    var row: Int
    var col: Int
}

enum GameColor: CaseIterable, Equatable {
    case red, purple, blue, yellow

    var color: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .yellow: .yellow
        case .purple: .purple
        }
    }
}

enum NodeType {
    case start, end
}

struct Node: Equatable {
    let color: GameColor
    let type: NodeType
}

enum Direction: CaseIterable {
    case up, down, left, right
}

struct GridCell {
    var node: Node?
    var pathColor: GameColor?
    var pathDirections: Set<Direction> = []
}

struct Puzzle {
    let endpoints: [Point: Node]
}

// MARK: - Tip Model
struct Tip {
    let title: String
    let content: String
}

// MARK: - ViewModel

class GameViewModel: ObservableObject {
    @Published var grid: [[GridCell]]
    @Published var isPuzzleSolved = false
    @Published var currentPuzzleIndex = 0
    @Published var showTip: Bool = false
    @Published var currentTip: Tip? = nil
    @Published var showOnboarding: Bool = true

    private var puzzles: [Puzzle]
    private var paths: [GameColor: [Point]] = [:]
    private var currentPath: [Point] = []
    private var currentPathColor: GameColor?

    // Placeholder: Map each color to a tip
    let tips: [GameColor: Tip] = [
        .red: Tip(title: "Red Tip Title", content: "Red tip content goes here."),
        .blue: Tip(title: "Blue Tip Title", content: "Blue tip content goes here."),
        .yellow: Tip(title: "Yellow Tip Title", content: "Yellow tip content goes here."),
        .purple: Tip(title: "Purple Tip Title", content: "Purple tip content goes here.")
    ]

    // Placeholder: Map each color to its solution path for the current puzzle
    // You will need to fill these in with the actual solution paths for your puzzles
    var solutionPaths: [GameColor: [Point]] {
        [
            .blue: [
                Point(row: 4, col: 1),
                Point(row: 0, col: 1),
                Point(row: 0, col: 3),
                Point(row: 2, col: 3)
            ],
            .purple: [
                Point(row: 3, col: 3),
                Point(row: 3, col: 4),
                Point(row: 0, col: 4),
                Point(row: 0, col: 0),
                Point(row: 5, col: 0)
            ],
            .red: [
                Point(row: 0, col: 5),
                Point(row: 5, col: 5),
                Point(row: 5, col: 1)
            ],
            .yellow: [
                Point(row: 2, col: 2),
                Point(row: 0, col: 2),
                Point(row: 0, col: 4),
                Point(row: 4, col: 4)
            ]
        ]

    }

    let gridSize = 6

    init() {
        self.puzzles = Self.createPuzzles()
        self.grid = Array(repeating: Array(repeating: GridCell(), count: 6), count: 6)
        loadPuzzle()
    }

    func nextPuzzle() {
        currentPuzzleIndex = (currentPuzzleIndex + 1) % puzzles.count
        loadPuzzle()
    }
    
    func restartPuzzle() {
        loadPuzzle()
    }

    private func loadPuzzle() {
        // Reset state
        grid = Array(repeating: Array(repeating: GridCell(), count: gridSize), count: gridSize)
        paths = [:]
        isPuzzleSolved = false
        currentPath = []
        currentPathColor = nil

        let puzzle = puzzles[currentPuzzleIndex]
        for (point, node) in puzzle.endpoints {
            grid[point.row][point.col].node = node
        }
    }

    // MARK: - Drag Gesture Handling
    
    func dragChanged(from startPoint: Point, to currentLocation: CGPoint, in frame: CGRect) {
        let cellWidth = frame.width / CGFloat(gridSize)
        let cellHeight = frame.height / CGFloat(gridSize)
        
        let currentCol = Int(currentLocation.x / cellWidth)
        let currentRow = Int(currentLocation.y / cellHeight)
        
        guard isValid(row: currentRow, col: currentCol) else { return }
        
        let newPoint = Point(row: currentRow, col: currentCol)
        
        // Start a new path
        if currentPath.isEmpty {
            guard let node = grid[startPoint.row][startPoint.col].node, node.type == .start else { return }
            
            let color = node.color
            // Clear existing path of the same color
            if let existingPath = paths[color] {
                clearPath(existingPath)
                paths[color] = nil
            }

            currentPathColor = color
            currentPath.append(startPoint)
            updateGridForCurrentPath()
        }
        
        guard let lastPoint = currentPath.last, newPoint != lastPoint else { return }
        
        // If we move back, shorten the path
        if currentPath.count > 1 && currentPath[currentPath.count - 2] == newPoint {
            let lastPoint = currentPath.removeLast()
            grid[lastPoint.row][lastPoint.col].pathColor = nil
            grid[lastPoint.row][lastPoint.col].pathDirections = []
            
            // Also update the directions of the new last point
            if let newLastPoint = currentPath.last {
                let index = currentPath.count - 1
                grid[newLastPoint.row][newLastPoint.col].pathDirections = getDirections(for: newLastPoint, at: index, in: currentPath)
            }
            return
        }

        guard isAdjacent(lastPoint, newPoint) else { return }

        // Prevent crossing itself (except for backtracking, handled above)
        if currentPath.contains(newPoint) { return }

        // Check if the new cell is valid to move into
        let cell = grid[newPoint.row][newPoint.col]
        let isOccupiedByOtherPath = cell.pathColor != nil && cell.pathColor != currentPathColor
        let isOccupiedByOtherNode = cell.node != nil && (cell.node?.color != currentPathColor || cell.node?.type == .start)

        if !isOccupiedByOtherPath && !isOccupiedByOtherNode {
            currentPath.append(newPoint)
            updateGridForCurrentPath()
        }
    }

    func dragEnded(on point: Point) {
        guard let color = currentPathColor, !currentPath.isEmpty else {
            currentPath = []
            currentPathColor = nil
            return
        }
        let endCell = grid[point.row][point.col]
        // If the drag ends on the correct end node, finalize the path (show tip if endpoints match)
        if endCell.node?.type == .end && endCell.node?.color == color {
            finalizeCurrentPath()
        } else {
            // Always persist the path, regardless of where the drag ends
            paths[color] = currentPath
            currentPath = []
            currentPathColor = nil
            checkWinCondition()
        }
    }
    
    // MARK: - Path Logic

    private func updateGridForCurrentPath() {
        guard let color = currentPathColor else { return }
        
        // Clear previous path appearance to handle backtracking
        for (i, point) in grid.enumerated() {
            for (j, _) in point.enumerated() {
                if grid[i][j].pathColor == color {
                    grid[i][j].pathColor = nil
                    grid[i][j].pathDirections = []
                }
            }
        }

        // Re-draw path based on currentPath
        for i in 0..<currentPath.count {
            let point = currentPath[i]
            grid[point.row][point.col].pathColor = color
            grid[point.row][point.col].pathDirections = getDirections(for: point, at: i, in: currentPath)
        }
    }
    
    private func finalizeCurrentPath() {
        guard let color = currentPathColor else { return }
        paths[color] = currentPath

        // Check if the path connects the correct start and end
        if let solution = solutionPaths[color],
           let userStart = currentPath.first,
           let userEnd = currentPath.last,
           let solStart = solution.first,
           let solEnd = solution.last,
           (userStart == solStart && userEnd == solEnd) || (userStart == solEnd && userEnd == solStart) {
            if let tip = tips[color] {
                currentTip = tip
                showTip = true
            }
        }

        currentPath = []
        currentPathColor = nil
    }

    private func clearPath(_ path: [Point]) {
        for point in path {
            let cell = grid[point.row][point.col]
            if cell.node == nil {
                grid[point.row][point.col].pathColor = nil
                grid[point.row][point.col].pathDirections = []
            } else {
                // if it's a node, just clear directions
                 grid[point.row][point.col].pathDirections = []
            }
        }
    }

    private func getDirections(for point: Point, at index: Int, in path: [Point]) -> Set<Direction> {
        var directions: Set<Direction> = []
        if index > 0 {
            directions.insert(direction(from: point, to: path[index - 1]))
        }
        if index < path.count - 1 {
            directions.insert(direction(from: point, to: path[index + 1]))
        }
        return directions
    }

    private func direction(from: Point, to: Point) -> Direction {
        if to.row < from.row { return .up }
        if to.row > from.row { return .down }
        if to.col < from.col { return .left }
        return .right
    }

    // MARK: - Helpers & Win Condition

    private func isValid(row: Int, col: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }

    private func isAdjacent(_ p1: Point, _ p2: Point) -> Bool {
        return abs(p1.row - p2.row) + abs(p1.col - p2.col) == 1
    }

    private func checkWinCondition() {
        let totalCells = gridSize * gridSize
        let pathCells = paths.values.reduce(0) { $0 + $1.count }
        let uniquePathCells = Set(paths.values.flatMap { $0 }).count
        
        let allEndpoints = puzzles[currentPuzzleIndex].endpoints.keys
        let connectedEndpointsCount = paths.keys.count * 2
        
        if pathCells == uniquePathCells && pathCells == totalCells && connectedEndpointsCount == allEndpoints.count {
            isPuzzleSolved = true
        }
    }
    
    // MARK: - Puzzle Data
    static func createPuzzles() -> [Puzzle] {
        return [
            // Verified, fillable, non-overlapping 6x6 Flow Free puzzle (Regular Pack, Level 1)
            // Puzzle from image
            Puzzle(endpoints: [
                Point(row: 4, col: 1): Node(color: .blue, type: .start),
                Point(row: 2, col: 3): Node(color: .blue, type: .end),

                Point(row: 3, col: 3): Node(color: .purple, type: .start),
                Point(row: 5, col: 0): Node(color: .purple, type: .end),

                Point(row: 0, col: 5): Node(color: .red, type: .start),
                Point(row: 5, col: 1): Node(color: .red, type: .end),

                Point(row: 2, col: 2): Node(color: .yellow, type: .start),
                Point(row: 4, col: 4): Node(color: .yellow, type: .end)
            ])


        ]
    }

    // Extracts the turn points (including start and end) from a path
    private func extractTurnPoints(from path: [Point]) -> [Point] {
        guard path.count > 1 else { return path }
        var turns: [Point] = [path[0]]
        var prevDirection: (Int, Int)? = nil
        for i in 1..<path.count {
            let dx = path[i].row - path[i-1].row
            let dy = path[i].col - path[i-1].col
            let dir = (dx, dy)
            if prevDirection == nil {
                prevDirection = dir
            } else if dir != prevDirection ?? (0,0) {
                turns.append(path[i-1])
                prevDirection = dir
            }
        }
        turns.append(path.last!)
        return turns
    }
}

// MARK: - Views

struct Game1view: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var dragStartPoint: Point? = nil
    @State private var showCompletionView = false

    var body: some View {
        VStack {
            Text("Puzzle \(viewModel.currentPuzzleIndex + 1)")
                .font(.largeTitle)
                .padding()

            GeometryReader { geometry in
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<viewModel.gridSize, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<viewModel.gridSize, id: \.self) { col in
                                    GridCellView(cell: viewModel.grid[row][col])
                                        .frame(width: geometry.size.width / CGFloat(viewModel.gridSize),
                                               height: geometry.size.height / CGFloat(viewModel.gridSize))
                                        .background(Color.black.opacity(0.1))
                                        .border(Color.gray.opacity(0.2))

                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let cellWidth = geometry.size.width / CGFloat(viewModel.gridSize)
                                let cellHeight = geometry.size.height / CGFloat(viewModel.gridSize)
                                
                                if dragStartPoint == nil {
                                    let startCol = Int(value.startLocation.x / cellWidth)
                                    let startRow = Int(value.startLocation.y / cellHeight)
                                    self.dragStartPoint = Point(row: startRow, col: startCol)
                                }
                                
                                viewModel.dragChanged(from: self.dragStartPoint!, to: value.location, in: geometry.frame(in: .local))
                            }
                            .onEnded { value in
                                let cellWidth = geometry.size.width / CGFloat(viewModel.gridSize)
                                let cellHeight = geometry.size.height / CGFloat(viewModel.gridSize)
                                let endCol = Int(value.location.x / cellWidth)
                                let endRow = Int(value.location.y / cellHeight)
                                viewModel.dragEnded(on: Point(row: endRow, col: endCol))
                                self.dragStartPoint = nil
                            }
                    )
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding()

            HStack {
                Button("Restart") {
                    viewModel.restartPuzzle()
                }
                .padding()
                
                Spacer()
                
                Button("Next") {
                    viewModel.nextPuzzle()
                }
                .padding()
            }
            .padding(.horizontal)
        }
        .onChange(of: viewModel.isPuzzleSolved) { solved in
            if solved {
                showCompletionView = true
            }
        }
        .sheet(isPresented: $showCompletionView, onDismiss: {
            viewModel.nextPuzzle()
        }) {
            PuzzleCompletionView()
        }
        .sheet(isPresented: $viewModel.showTip, onDismiss: {
            viewModel.currentTip = nil
        }) {
            if let tip = viewModel.currentTip {
                TipView(tip: tip)
            }
        }
        .sheet(isPresented: $viewModel.showOnboarding) {
            OnboardingView()
        }
    }
}

struct PuzzleCompletionView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("🎉 Puzzle Solved! 🎉")
                .font(.largeTitle)
                .bold()
                .padding()
            Text("Great job! Ready for the next puzzle?")
                .font(.title2)
            Spacer()
        }
        .padding()
    }
}

struct TipView: View {
    let tip: Tip
    var body: some View {
        VStack(spacing: 24) {
            Text(tip.title)
                .font(.title)
                .bold()
                .padding()
            Text(tip.content)
                .font(.body)
            Spacer()
        }
        .padding()
    }
}

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Redhill!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                OnboardingStep(
                    number: 1,
                    text: "Connect the correct villager and drag him to the correct tree! You cannot drag through trees, other villagers, or their paths! You can click on the villager to restart the path, and the restart button at the bottom to restart everything!"
                )
                
                OnboardingStep(
                    number: 2,
                    text: "When you successfully bring a villager to their tree, you will receive a historical fact about Redhill!"
                )
                
                OnboardingStep(
                    number: 3,
                    text: "Remember, you have to match the colours - but don't forget to drag the villager to the tree, and not the tree to the villager!"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text("Good Luck!")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            Button("Let's Start!") {
                dismiss()
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

struct OnboardingStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(number)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

struct GridCellView: View {
    let cell: GridCell
    
    private func findFile(type: String, Color: String) -> String {
        print(Color + type)
        return Color + type
    }
    
    var body: some View {
        ZStack {
            if let pathColor = cell.pathColor {
                PipeView(directions: cell.pathDirections)
                    .stroke(pathColor.color, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
            }
            
            if let node = cell.node {
                switch node.type {
                case .start:
                    let file = findFile(type: "ppl", Color: node.color.color.description)
                    Image(file)
                        .resizable()
                        .frame(width: 150, height: 150)
                case .end:
                    let file = findFile(type: "tree", Color: node.color.color.description)
                    Image(file)
                        .resizable()
                        .frame(width: 120, height: 120)
                }
            }
        }
    }
}

struct PipeView: Shape {
    let directions: Set<Direction>

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        for direction in directions {
            path.move(to: center)
            switch direction {
            case .up:
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            case .down:
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            case .left:
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            case .right:
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
        }
        return path
    }
}


#Preview {
    Game1view()
}
