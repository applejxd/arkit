//
//  ContentView.swift
//  arkit-experiment
//
//  Created by applejxd on 2023/07/09.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var cam_position: simd_float3 = simd_float3(0, 0, 0)
    
    var body: some View {
        VStack {
            // 画面をエッジまで拡張
            ARViewContainer(cam_position: $cam_position).edgesIgnoringSafeArea(.all).frame(height: 600)
            
            LabelView(cam_position: $cam_position).padding(.leading, 150)
//            Text("(\(self.cam_position.x),\(self.cam_position.y),\(self.cam_position.z)").padding()
        }
    }
}

struct LabelView: UIViewRepresentable {
    @Binding var cam_position: simd_float3
    
    func makeUIView(context: Context) -> UILabel {
        let labelView:UILabel = UILabel()
        // 改行を可能に
        labelView.numberOfLines = 0
        // 左寄せ
        labelView.textAlignment = NSTextAlignment.left
        labelView.text = "x=0,\ny=0\nz=0"

        return labelView // ビューを返す
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        let x_str = String(format: "%.3f", cam_position.x)
        let y_str = String(format: "%.3f", cam_position.y)
        let z_str = String(format: "%.3f", cam_position.z)
        uiView.text = "x=\(x_str),\ny=\(y_str),\nz=\(z_str)"
    }
}

// AR 表示
// cf. https://www.ralfebert.com/ios/realitykit-dice-tutorial/
struct ARViewContainer: UIViewRepresentable {
    @Binding var cam_position: simd_float3
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        // delegate にユーザ定義の Coodinator を設定.
        // 後述の makeCoordinator と Coordinator を定義しないとエラー.
        arView.session.delegate = context.coordinator

        // トラッキング設定
        // cf. https://developer.apple.com/documentation/arkit/arworldtrackingconfiguration
        let config = ARWorldTrackingConfiguration()
        // 平面検知 ON
        config.planeDetection = [.horizontal]
        // LiDAR からのメッシュ生成 ON
        // .mesh はメッシュ判定のみ/.meshWithClassification は種別判定も実施
        // cf. https://www.toyship.org/2020/03/30/150924
        config.sceneReconstruction = .meshWithClassification
        
        // AR セッションを開始
        let session = arView.session
        session.run(config)

        #if DEBUG
        // デバッグ情報重畳表示 (原点・特徴点・メッシュ形状)
        // cf. https://developer.apple.com/documentation/realitykit/arview/debugoptions-swift.struct
        arView.debugOptions = [.showWorldOrigin, .showFeaturePoints, .showSceneUnderstanding]
        #endif
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(cam_position: $cam_position)
    }
    
    // cf. https://qiita.com/kazy_dev/items/f0850d7ee22d84192639#swiftuisearchview%E3%81%A8coordinator%E3%81%AB%E3%82%82text%E3%82%92%E4%BF%9D%E6%8C%81%E3%81%99%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB%E3%83%97%E3%83%AD%E3%83%91%E3%83%86%E3%82%A3%E3%81%A8%E5%87%A6%E7%90%86%E3%82%92%E8%BF%BD%E5%8A%A0
    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var cam_position: simd_float3
        
        init(cam_position: Binding<simd_float3>) {
            _cam_position = cam_position
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // cf. https://rockyshikoku.medium.com/get-the-location-of-the-device-with-arkit-4e4c54831fbc
            let transform: simd_float4 = frame.camera.transform.columns.3
            let devicePosition: simd_float3 = simd_float3(x: transform.x, y: transform.y, z: transform.z)
            self.cam_position = devicePosition
        }
    }
}

// デバッグ用に作成中の画面を Xcode で Preview 表示
#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
