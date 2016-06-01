public struct Edit<T: Equatable> {
    public typealias Index = Int

    public let action: EditAction
    public let value: T
    public let destination: Index
}

extension Edit: Equatable { }

extension Edit: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Edit: <\(action) \"\(value)\" at \(destination)>"
    }
}

public func ==<T: Equatable> (lhs: Edit<T>, rhs: Edit<T>) -> Bool {
    return lhs.value == rhs.value &&
        lhs.action == rhs.action &&
        lhs.destination == rhs.destination
}

public enum EditAction {
    case Insert
    case Substitute
    case Delete
    case Move
}

extension EditAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Insert: return "Insert"
        case .Substitute: return "Substitute"
        case .Delete: return "Delete"
        case .Move: return "Move"
        }
    }
}


struct Matrix<T> {
    private let rows: Int
    private let columns: Int
    private var storage: [T]

    init(rows: Int, columns: Int, repeatedValue: T) {
        self.rows = rows
        self.columns = columns
        self.storage = Array(count: rows * columns, repeatedValue: repeatedValue)
    }

    init(contents: [[T]]) {
        let fittingSize = contents.first?.count ?? 0
        let allFittingSize = contents.reduce(true) { (acc, next) -> Bool in
            return next.count == fittingSize
        }
        precondition(allFittingSize)

        self.rows = contents.count
        self.columns = fittingSize
        self.storage = Array(contents.flatten())
    }

    private func validIndexFor(row row: Int, column: Int) -> Bool {
        return row >= 0 &&
            row < rows &&
            column >= 0 &&
            column < columns
    }

    subscript(row: Int, column: Int) -> T {
        get {
            precondition(validIndexFor(row: row, column: column), "Index out of range")
            return storage[(row * columns) + column]
        }

        set {
            precondition(validIndexFor(row: row, column: column), "Index out of range")
            storage[(row * columns) + column] = newValue
        }
    }
}


func ==<T: Equatable> (lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
    return lhs.storage == rhs.storage
}

/// Used to calculate the difference between two Array<T: Equatable>
public struct ArrayDiffCalculator<T: Equatable> {
    public static func calculateDiff(origin origin: [T], destination: [T]) -> [Edit<T>] {
        // The resulting matrix must allow for no edits at (0,0)
        let matrixRowDepth = origin.count + 1
        let matrixColumnWidth = destination.count + 1

        // A matrix of arrays of edits, from origin to destination
        var distanceMatrix: Matrix<[Edit<T>]> = Matrix(rows: matrixRowDepth, columns: matrixColumnWidth, repeatedValue: [])

        // Calculate the distance of any first T to an empty second T
        var deleteSourceEdits = [Edit<T>]()
        for (index, value) in origin.enumerate() {
            deleteSourceEdits.append(Edit(action: .Delete, value: value, destination: index))
            distanceMatrix[index + 1, 0] = deleteSourceEdits
        }

        // Calculate the distance of any second T to an empty first T
        var insertSourceEdits = [Edit<T>]()
        for (index, value) in destination.enumerate() {
            insertSourceEdits.append(Edit(action: .Insert, value: value, destination: index))
            distanceMatrix[0, index + 1] = insertSourceEdits
        }

        for (destinationIndex, destinationValue) in destination.enumerate() {
            for (originIndex, originValue) in origin.enumerate() {
                if originValue == destinationValue {
                    // No operation required
                    distanceMatrix[originIndex + 1, destinationIndex + 1] = distanceMatrix[originIndex, destinationIndex]
                } else {
                    var editsForDeletion = distanceMatrix[originIndex, destinationIndex + 1]
                    var editsForInsertion = distanceMatrix[originIndex + 1, destinationIndex]
                    var editsForSubstitution = distanceMatrix[originIndex, destinationIndex]

                    let minimum: [Edit<T>]
                    if editsForDeletion.count <= editsForInsertion.count && editsForDeletion.count <= editsForSubstitution.count {
                        editsForDeletion.append(Edit(action: .Delete, value: originValue, destination: originIndex))
                        minimum = editsForDeletion
                    } else if editsForInsertion.count <= editsForDeletion.count && editsForInsertion.count <= editsForSubstitution.count {
                        editsForInsertion.append(Edit(action: .Insert, value: destinationValue, destination: destinationIndex))
                        minimum = editsForInsertion
                    } else if editsForSubstitution.count <= editsForDeletion.count && editsForSubstitution.count <= editsForInsertion.count {
                        editsForSubstitution.append(Edit(action: .Substitute, value: destinationValue, destination: destinationIndex))
                        minimum = editsForSubstitution
                    } else {
                        fatalError()
                    }

                    distanceMatrix[originIndex + 1, destinationIndex + 1] = minimum
                }
            }
        }

        return distanceMatrix[origin.count, destination.count]
    }
}
