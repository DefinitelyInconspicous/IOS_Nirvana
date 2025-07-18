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

struct Tip {
    let icon: String
    let title: [String: String]  // Language: Title
    let content: [String: String]  // Language: Content

    func localizedTitle(for language: String) -> String {
        return title[language] ?? title["English"] ?? ""
    }

    func localizedContent(for language: String) -> String {
        return content[language] ?? content["English"] ?? ""
    }
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
    let tips: [GameColor: Tip] = [
        .red: Tip(
            icon: "flame.fill",
            title: [
                "English": "Origin of the Name 'Redhill'",
                "Chinese": "红山名字的由来",
                "Malay": "Asal-usul Nama 'Redhill'",
                "Tamil": "‘ரெட்ஹில்’ எனும் பெயரின் தோற்றம்"
            ],
            content: [
                "English": "The name 'Redhill' comes from red soil seen after the tragic event.",
                "Chinese": "“红山”的名字来源于悲剧事件后看到的红色泥土。",
                "Malay": "Nama 'Redhill' berasal daripada tanah merah selepas kejadian tragis itu.",
                "Tamil": "'ரெட்ஹில்' என்ற பெயர் ஒரு துயர நிகழ்வுக்குப் பிறகு காணப்பட்ட சிவப்பு மண்ணிலிருந்து வந்தது."
            ]
        ),
        .blue: Tip(
            icon: "sailboat.fill",
            title: [
                "English": "Connection to Maritime History",
                "Chinese": "与海事历史的联系",
                "Malay": "Kaitan dengan Sejarah Maritim",
                "Tamil": "கடல் வரலாற்றுடன் உள்ள தொடர்பு"
            ],
            content: [
                "English": "Redhill was once near a fishing village, important in maritime history.",
                "Chinese": "红山曾靠近一个渔村，与海事历史密切相关。",
                "Malay": "Redhill dahulunya berhampiran perkampungan nelayan, penting dalam sejarah maritim.",
                "Tamil": "ரெட்ஹில் ஒரு மீனவர்கள் கிராமத்திற்கு அருகிலிருந்தது, கடல் வரலாற்றில் முக்கியமானது."
            ]
        ),
        .yellow: Tip(
            icon: "book.fill",
            title: [
                "English": "Symbolic Use in Education",
                "Chinese": "教育中的象征意义",
                "Malay": "Penggunaan Simbolik dalam Pendidikan",
                "Tamil": "கல்வியில் பிரதிநிதித்துவ பயன்பாடு"
            ],
            content: [
                "English": "The legend is used in schools to teach selflessness and vigilance.",
                "Chinese": "这个传说在学校中用于教授无私和警觉。",
                "Malay": "Legenda ini digunakan di sekolah untuk mengajar keikhlasan dan kewaspadaan.",
                "Tamil": "தன்னலமின்மை மற்றும் விழிப்புணர்வை கற்றுத்தர இந்த கதையை பள்ளிகளில் பயன்படுத்துகின்றனர்."
            ]
        ),
        .purple: Tip(
            icon: "mountain.2.fill",
            title: [
                "English": "Geographic Shift of the Hill",
                "Chinese": "山地的地理变化",
                "Malay": "Perubahan Geografi Bukit",
                "Tamil": "மலையின் புவியியல் மாற்றம்"
            ],
            content: [
                "English": "The original Redhill was leveled during Singapore’s urban development.",
                "Chinese": "原始的红山在新加坡城市发展中被夷平。",
                "Malay": "Redhill asal diratakan semasa pembangunan bandar Singapura.",
                "Tamil": "சிங்கப்பூரின் நகர வளர்ச்சியின் போது ஆரம்ப ரெட்ஹில் தட்டுவதாக மாறியது."
            ]
        )
    ]


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
        
        
        if currentPath.isEmpty {
            guard let node = grid[startPoint.row][startPoint.col].node, node.type == .start else { return }
            
            let color = node.color
            
            if let existingPath = paths[color] {
                clearPath(existingPath)
                paths[color] = nil
            }
            
            currentPathColor = color
            currentPath.append(startPoint)
            updateGridForCurrentPath()
        }
        
        guard let lastPoint = currentPath.last, newPoint != lastPoint else { return }
        
        
        if currentPath.count > 1 && currentPath[currentPath.count - 2] == newPoint {
            let lastPoint = currentPath.removeLast()
            grid[lastPoint.row][lastPoint.col].pathColor = nil
            grid[lastPoint.row][lastPoint.col].pathDirections = []
            
            if let newLastPoint = currentPath.last {
                let index = currentPath.count - 1
                grid[newLastPoint.row][newLastPoint.col].pathDirections = getDirections(for: newLastPoint, at: index, in: currentPath)
            }
            return
        }
        
        guard isAdjacent(lastPoint, newPoint) else { return }
        
        if currentPath.contains(newPoint) { return }
        
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
        if endCell.node?.type == .end && endCell.node?.color == color {
            finalizeCurrentPath()
        } else {
            paths[color] = currentPath
            currentPath = []
            currentPathColor = nil
        }
        checkWinCondition()
    }
    
    // MARK: - Path Logic
    
    private func updateGridForCurrentPath() {
        guard let color = currentPathColor else { return }
        
        for (i, point) in grid.enumerated() {
            for (j, _) in point.enumerated() {
                if grid[i][j].pathColor == color {
                    grid[i][j].pathColor = nil
                    grid[i][j].pathDirections = []
                }
            }
        }
        
        
        for i in 0..<currentPath.count {
            let point = currentPath[i]
            grid[point.row][point.col].pathColor = color
            grid[point.row][point.col].pathDirections = getDirections(for: point, at: i, in: currentPath)
        }
    }
    
    private func finalizeCurrentPath() {
        guard let color = currentPathColor else { return }
        paths[color] = currentPath
        
        
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
        print("Checking win condition")
        let totalCells = gridSize * gridSize
        let pathCells = paths.values.reduce(0) { $0 + $1.count }
        let uniquePathCells = Set(paths.values.flatMap { $0 }).count
        
        let allEndpoints = puzzles[currentPuzzleIndex].endpoints.keys
        let connectedEndpointsCount = paths.keys.count * 2
        
        if pathCells == uniquePathCells && pathCells == totalCells && connectedEndpointsCount == allEndpoints.count {
            print(pathCells)
            print(uniquePathCells)
            print(totalCells)
            print(connectedEndpointsCount)
            isPuzzleSolved = true
        }
    }
    
    // MARK: - Puzzle Data
    static func createPuzzles() -> [Puzzle] {
        return [
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
    @Binding var language: String
    @State private var dragStartPoint: Point? = nil
    @State private var showCompletionView = false
    @State private var elapsedTime: Int = 0
    @State private var timer: Timer? = nil
    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    
    var body: some View {
        VStack {
            Text("Time: \(formattedTime)")
                .font(.title2)
                .bold()
                .padding(.top, 12)
            
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
        }
        .onAppear {
            elapsedTime = 0
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedTime += 1
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: viewModel.isPuzzleSolved) { solved in
            if solved {
                timer?.invalidate()
                    showCompletionView = true
                
            }
        }
        
        .sheet(isPresented: $showCompletionView) {
            VideoView(language: .constant(language), part: .constant(2))
        }
        
        .sheet(isPresented: $viewModel.showTip) {
            if let tip = viewModel.currentTip {
                TipView(tip: tip, language: $language)
            }
        }

        
        
        .onChange(of: viewModel.showTip) { showTip in
            if showTip {
                viewModel.showTip = true
                
            }
        }
        
        .sheet(isPresented: $viewModel.showOnboarding) {
            OnboardingView(language: $language)
        }
    }
}


#Preview {
    Game1view(language: .constant("English"))
}
