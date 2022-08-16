//
//  ContentView.swift
//  HelloBybit
//  
//  Created on 2022/08/15
//  
//

import SwiftUI

class ContentViewModel: ObservableObject {
    private let model = BybitModel()
    @Published var wallet = BybitWalletBalance()
    
    func update() {
        model.fetch(completion: { (wallet) in
            self.wallet = wallet
        })
    }
}

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    RefreshControl(coordinateSpaceName: "RefreshControl", onRefresh: {
                        print("doRefresh()")
                        viewModel.update()
                    })
                    
                    HStack(spacing: 0) {
                        Image("bybit")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, alignment: .leading)
                            .padding(.trailing, 8)
                        Text("Wallet Balance")
                            .font(.title)
                    }
                    
                    WalletBalanceView(wallet: viewModel.wallet)
                        .frame(minHeight: geometry.size.height * 0.9)
                }
            }
            .coordinateSpace(name: "RefreshControl")
        }.onAppear {
            viewModel.update()
        }
    }
}

struct WalletBalanceView: View {
    var wallet: BybitWalletBalance
    
    var body: some View {
        List() {
            Section(header: Text("資産合計 USD")) {
                ListItemView(name: "BTC換算", value: wallet.total.lastAmount.toDecimalString + " USD")
                //ListItemView(name: "24時間前", value: wallet.total.openAmount.toDecimalString + " USD")
            }
            Section(header: Text("資産合計 JPY")) {
                ListItemView(name: "円換算", value: exchage(wallet.total.lastAmount).toIntegerString + " 円")
                ListItemView(name: "米ドル円レート", value: wallet.USDJPY.toDecimalString + " 円")
                ListItemView(name: "24時間前", value: exchage(wallet.total.openAmount).toIntegerString + " 円")
                ListItemView(name: "増減", value: delta(wallet.total.openAmount, wallet.total.lastAmount).toIntegerString + " 円")
                ListItemView(name: "比率", value: deltaRatio(wallet.total.openAmount, wallet.total.lastAmount).toPercentString)
            }
            Section(header: Text("資産内訳")) {
                ListItemView(name: "現物", value: exchage(wallet.spot.lastAmount).toIntegerString + " 円")
                ListItemView(name: "デリバティブ", value: exchage(wallet.derivatives.lastAmount).toIntegerString + " 円")
                ListItemView(name: "ステーキング", value: exchage(wallet.staking.lastAmount).toIntegerString + " 円")
            }
        }
    }
    
    private func exchage(_ usd: Double) -> Double {
        return usd * wallet.USDJPY
    }

    private func delta(_ from: Double, _ to: Double) -> Double {
        return to - from
    }

    private func deltaRatio(_ from: Double, _ to: Double) -> Double {
        return delta(from, to) / from
    }

}

struct ListItemView: View {
    var name: String
    var value: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct RefreshControl: View {
    @State private var isRefreshing = false
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    let haptics = UINotificationFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .named(coordinateSpaceName)).midY > 30 {
                Spacer()
                    .onAppear() {
                        haptics.notificationOccurred(.success) // 触覚フィードバック
                        isRefreshing = true
                    }
            } else if geometry.frame(in: .named(coordinateSpaceName)).maxY < 10 {
                Spacer()
                    .onAppear() {
                        if isRefreshing {
                            isRefreshing = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if isRefreshing {
                    ProgressView()
                } else {
                    Text("↓")
                        .font(.system(size: 28))
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Double {
    var toDecimalString: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2 // 1234.5 -> 1,234.50
        f.maximumFractionDigits = 2 // 1234.567 -> 1,234.57
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var toIntegerString: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0 // 1234.5 -> 1,235
        f.maximumFractionDigits = 0 // 1234.567 -> 1,235
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var toPercentString: String {
        let f = NumberFormatter()
        f.numberStyle = .percent
        return f.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
