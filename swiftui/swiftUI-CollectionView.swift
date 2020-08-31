import SwiftUI
import Foundation

struct Layout {
    static let CollectionCellSpacing = 2.0
}

struct CollectionView: View {

    @State var collectionViewRows: Int
    @State var collectionViewColumns: Int
    
    var body: some View {
        GeometryReader { geometry in
            self.makeCollectionView(geometry: geometry)
        }
    }

    func makeCollectionView(geometry: GeometryProxy) -> some View {
        return AnyView(ScrollView(showsIndicators: false) {
            VStack(alignment: .center, spacing: Layout.CollectionCellSpacing ) {
                ForEach(0 ..< collectionViewRows, id: \.self) { row in
                    HStack(alignment: .center, spacing: Layout.CollectionCellSpacing ) {
                        ForEach(0 ..< collectionViewColumns, id: \.self) { column in
                            ZStack {
                                self.makeCollectionViewCell()
                            }
                        }
                    }
                }
            }
        }
    }

    func makeCollectionViewCell() {
        return Text("Hello")
    }
}
