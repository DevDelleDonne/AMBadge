import SwiftUI

public struct AMBadge: View {
    
    let title: String
    let subtitle: String?
    let icon: UIImage?
    
    var backgroundColor: Color = Color(.secondarySystemBackground)
    
    public var body: some View {
        if subtitle == nil {
            Text(title)
                .background {
                    backgroundColor
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 8)
                .clipShape(RoundedRectangle(cornerRadius: 9))
        } else {
            VStack {
                Text(title)
                Text(subtitle ?? "")
            }
        }
    }
}
